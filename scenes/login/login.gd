extends Panel

signal sign_up
signal log_in(username: String, password, String, remember_me: bool)

@export var username_prompt: LineEdit
@export var password_prompt: LineEdit
@export var remember_me: CheckButton
@export var error_label: Label

func _on_sign_up_meta_clicked(meta: Variant) -> void:
	if str(meta) == "sign_up":
		sign_up.emit()


func _on_submit_pressed() -> void:
	log_in.emit(username_prompt.text, password_prompt.text, remember_me.button_pressed)
