extends Panel

signal log_in
signal sign_up(email: String, username: String, password: String)

const ERROR_LIFE_TIME = 3
const ERROR_FADE_TIME = 3

@export var email_prompt: LineEdit
@export var username_prompt: LineEdit
@export var password_prompt: LineEdit
@export var password_re_prompt: LineEdit

@export var error_label: Label

func _on_sign_up_meta_clicked(meta: Variant) -> void:
	if str(meta) == "log_in":
		log_in.emit()

var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_submit_pressed() -> void:
	if email_prompt.text.is_empty() or username_prompt.text.is_empty() or password_prompt.text.is_empty() or password_re_prompt.text.is_empty():
		error_generator.error("Please fill out all of the fields!", error_label)
		return
	elif password_prompt.text != password_re_prompt.text:
		error_generator.error("Entered passwords are not the same.", error_label)
		return
	elif password_prompt.text.length() < 8:
		error_generator.error("Password must be at least 8 characters long.", error_label)
		return
	elif (password_prompt.text.is_valid_ascii_identifier() and !password_prompt.text.contains("_"))\
				or (password_prompt.text.left(1).is_valid_int() and password_prompt.text.right(-1).is_valid_ascii_identifier()):
		error_generator.error("Entered password must contain at least 1 special character.", error_label)
		return
	elif password_prompt.text == password_prompt.text.to_lower() or password_prompt.text == password_prompt.text.to_upper():
		error_generator.error("Entered password must contain at least 1 uppercase and lowercase character.\n(sorry this is a silent wolf thing I don't make the rules.)", error_label)
		return
	
	sign_up.emit(email_prompt.text, username_prompt.text, password_prompt.text)
	await error_generator.finished
