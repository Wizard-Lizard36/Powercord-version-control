extends Control

const LOGIN = preload("uid://4cv5jv1to8tf")
const SIGNUP = preload("uid://bt2yw2vyn3jq3")
const EMAIL_CONFIRMATION = preload("uid://b7s2io2bt77le")

var login: Panel
var signup: Panel
var email_confirmation: Panel
var friends: Panel

var remember_me: bool = false:
	set(new_val):
		remember_me = new_val
		Config.set_config_value("QOL", "remember_me", remember_me)


func _ready() -> void:
	remember_me = Config.get_config_value("QOL", "remember_me")
	if remember_me:
		Talo.player_auth.start_session()
	Talo.player_auth.session_found.connect(_session_found)
	Talo.player_auth.session_not_found.connect(_session_not_found)

## Emitted if the user does not need to re log-in.
func _session_found() -> void:
	GlobalVariables.logged_in = true
## Emitted if the user does need to re log-in.
func _session_not_found() -> void:
	GlobalVariables.session_not_found = true




var login_error_generator: ExtraFeatures = ExtraFeatures.new()
## Attempt to log the player in using Talo's player authentication.
func log_in_attempt(username: String, password: String, _remember_me: bool = true) -> void:
	remember_me = _remember_me
	var res: PlayerAuthAPI.LoginResult = await Talo.player_auth.login(username, password)
	match res:
		Talo.player_auth.LoginResult.FAILED:
			match Talo.player_auth.last_error.get_code():
				TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
					login_error_generator.error("Username or password is incorrect", login.error_label)
				_:
					login_error_generator.error(Talo.player_auth.last_error.get_string(), login.error_label)
		Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
			open_email_confirmation_screen()
		Talo.player_auth.LoginResult.OK:
			GlobalVariables.logged_in = true
			login.queue_free()

var registration_error_generator: ExtraFeatures = ExtraFeatures.new()
## Attempt to sign the player up using Talo's player authentication.
func sign_up_attempt(email: String, username: String, password: String) -> void:
	var res = await Talo.player_auth.register(username, password, email, true)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				registration_error_generator.error("Username is already taken.", signup.error_label)
			TaloAuthError.ErrorCode.IDENTIFIER_PROFANITY:
				registration_error_generator.error("Username is not allowed.", signup.error_label)
			_:
				registration_error_generator.error(Talo.player_auth.last_error.get_string(), signup.error_label)
	else:
		GlobalVariables.logged_in = true
		signup.queue_free()


func _open_login_screen() -> void:
	if login:
		return
	clear_screens()
	login = LOGIN.instantiate()
	add_child(login)
	login.log_in.connect(log_in_attempt)
	login.sign_up.connect(_open_sign_up_screen)

func _open_sign_up_screen() -> void:
	if signup:
		return
	clear_screens(signup)
	signup = SIGNUP.instantiate()
	add_child(signup)
	signup.sign_up.connect(sign_up_attempt)
	signup.log_in.connect(_open_login_screen)

func open_email_confirmation_screen():
	if email_confirmation:
		return
	clear_screens(email_confirmation)
	email_confirmation = EMAIL_CONFIRMATION.instantiate()
	add_child(email_confirmation)

func clear_screens(exeption: Node = null) -> void:
	if login and login != exeption:
		login.queue_free()
	if signup and signup != exeption:
		signup.queue_free()
	if friends and friends != exeption:
		friends.queue_free()

func _open_friends_screen() -> void:
	if friends:
		return
	clear_screens(friends)
	
