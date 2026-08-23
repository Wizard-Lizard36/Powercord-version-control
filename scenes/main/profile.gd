extends MenuButton

signal open_login_screen

func _on_pressed() -> void:
	if !GlobalVariables.logged_in:
		get_popup().hide()
		open_login_screen.emit()
