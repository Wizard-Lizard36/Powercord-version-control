extends Control

const LOGIN = preload("uid://4cv5jv1to8tf")
const SIGNUP = preload("uid://bt2yw2vyn3jq3")
const EMAIL_CONFIRMATION = preload("uid://b7s2io2bt77le")
const FRIENDS = preload("uid://c2y5l3lbbsku6")
const SERVER_CREATION = preload("uid://dfm72lr453dkv")

@export var servers_squasher: HSplitContainer

var login: Panel
var signup: Panel
var email_confirmation: Panel
var friends: Panel
var server_creation: Panel


var remember_me: bool = false:
	set(new_val):
		remember_me = new_val
		Config.set_config_value("QOL", "remember_me", remember_me)


func _ready() -> void:
	remember_me = Config.get_config_value("QOL", "remember_me")
	if remember_me or true:
		Talo.player_auth.start_session()
	Talo.player_auth.session_found.connect(_session_found)
	Talo.player_auth.session_not_found.connect(_session_not_found)


## Emitted if the user does not need to log in again.
func _session_found() -> void:
	GlobalVariables.logged_in = true
	OnlineSaves.load_latest()


## Emitted if the user does need to log in again.
func _session_not_found() -> void:
	GlobalVariables.session_not_found = true


var login_error_generator: ExtraFeatures = ExtraFeatures.new()
## Attempt to log the player in using Talo's player authentication.
func log_in_attempt(username: String, password: String, _remember_me: bool = true) -> void:
	remember_me = _remember_me
	var res: PlayerAuthAPI.PlayerAuthLoginResult = await Talo.player_auth.login(username, password)
	if res.verification_required:
		open_email_confirmation_screen()
		
	elif res.success:
		OnlineSaves.load_latest()
		GlobalVariables.logged_in = true
		login.queue_free()
	else:
		match res.error.code:
			TaloPlayerAuthError.ErrorCode.INVALID_CREDENTIALS:
				login_error_generator.error("Username or password is incorrect", login.error_label)
			_:
				login_error_generator.error(Talo.player_auth.last_error.get_string(), login.error_label)



var registration_error_generator: ExtraFeatures = ExtraFeatures.new()
## Attempt to sign the player up using Talo's player authentication.
func sign_up_attempt(email: String, username: String, password: String) -> void:
	var res = await Talo.player_auth.register(username, password, email, true)
	if !res.success:
		match res.error.code:
			TaloPlayerAuthError.ErrorCode.IDENTIFIER_TAKEN:
				registration_error_generator.error("Username is already taken.", signup.error_label)
			TaloPlayerAuthError.ErrorCode.IDENTIFIER_PROFANITY:
				registration_error_generator.error("Username is not allowed.", signup.error_label)
			_:
				registration_error_generator.error(res.error.message, signup.error_label)
	else:
		GlobalVariables.logged_in = true
		signup.queue_free()

func create_server(server_name: String, private: bool) -> void:
	var channel_options: ChannelsAPI.CreateChannelOptions = ChannelsAPI.CreateChannelOptions.new()
	channel_options.auto_cleanup = true
	channel_options.name = server_name
	channel_options.private = private
	await Talo.channels.create(channel_options)
	await servers_squasher.update_servers()
	servers_squasher.update_server_list()

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
	clear_screens()
	signup = SIGNUP.instantiate()
	add_child(signup)
	signup.sign_up.connect(sign_up_attempt)
	signup.log_in.connect(_open_login_screen)

func open_email_confirmation_screen():
	if email_confirmation:
		return
	clear_screens()
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
	clear_screens()
	
	friends = FRIENDS.instantiate()
	add_child(friends)


func _open_server_creation() -> void:
	if server_creation:
		return
	clear_screens()
	
	server_creation = SERVER_CREATION.instantiate()
	server_creation.create_server.connect(create_server)
	add_child(server_creation)
