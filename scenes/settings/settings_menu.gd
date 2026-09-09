extends Panel

@export var use_email_verification: CheckButton
@export var enter_password: Panel
@export var error_label: Label
@export var password_prompt: LineEdit


func _enter_tree() -> void:
	use_email_verification.button_pressed = GlobalVariables.using_email_verification


func _on_x_pressed() -> void:
	queue_free()

var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_use_email_verification_toggled(toggled_on: bool) -> void:
	if !GlobalVariables.users_password:
		enter_password.show()
	else:
		if !(await set_verification(toggled_on)):
			use_email_verification.set_pressed_no_signal(!toggled_on)


func set_verification(on: bool) -> bool:
	var res: PlayerAuthAPI.PlayerAuthResult = await Talo.player_auth.toggle_verification(GlobalVariables.users_password, on)
	if res.success:
		GlobalVariables.using_email_verification = on
		return true
	else:
		error_generator.error(res.error.message, error_label)
		return false


func _on_confirm_pressed() -> void:
	GlobalVariables.users_password = password_prompt.text
	if !(await set_verification(use_email_verification.button_pressed)):
		GlobalVariables.users_password = ""
	else:
		enter_password.hide()
