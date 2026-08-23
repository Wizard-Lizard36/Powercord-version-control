extends Control

const LOGIN = preload("uid://4cv5jv1to8tf")
const SIGNUP = preload("uid://bt2yw2vyn3jq3")

var login: Panel
var signup: Panel

func _ready() -> void:
	SilentWolf.configure({
	"api_key": "UxSsii49Eq4avnqUVMkyv1RnPBDZtKfr9etI311m",
	"game_id": "powercord",
	"log_level": 0
	})
	SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/MainPage.tscn"
	})
	SilentWolf.configure_auth({})
	
	SilentWolf.Auth.sw_login_complete.connect(_login_complete)
	SilentWolf.Auth.sw_registration_complete.connect(_registration_complete)


func _open_login_screen() -> void:
	if login:
		return
	if signup:
		signup.queue_free()
	login = LOGIN.instantiate()
	add_child(login)
	login.log_in.connect(log_in_attempt)
	login.sign_up.connect(_open_sign_up_screen)

func _open_sign_up_screen() -> void:
	if signup:
		return
	if login:
		login.queue_free()
	signup = SIGNUP.instantiate()
	add_child(signup)
	signup.sign_up.connect(sign_up_attempt)
	signup.log_in.connect(_open_login_screen)

func log_in_attempt(username: String, password: String, remember_me: bool = true) -> void:
	SilentWolf.Auth.login_player(username, password, remember_me)
	if str(SilentWolf.Auth.logged_in_player) == username:
		print("Signed in as %s !" % username)
		login.queue_free()

func sign_up_attempt(email: String, username: String, password: String) -> void:
	SilentWolf.Auth.register_player(username, email, password, password)

var login_error_generator: ExtraFeatures = ExtraFeatures.new()
func _login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		login.queue_free()
	else:
		login_error_generator.error(str(sw_result.error), login.error_label)

var registration_error_generator: ExtraFeatures = ExtraFeatures.new()
func _registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		signup.queue_free()
	else:
		registration_error_generator.error("Backend registration failed with error:\n" + str(sw_result.error), signup.error_label)
