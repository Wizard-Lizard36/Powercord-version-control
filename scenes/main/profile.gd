extends MenuButton

signal open_login_screen
signal open_friends_list
signal open_server_creation
signal open_settings

func _ready() -> void:
	get_popup().id_pressed.connect(_item_pressed)

func _item_pressed(id: int) -> void:
	match id:
		0:
			open_friends_list.emit()
		1:
			open_server_creation.emit()
		2:
			open_settings.emit()
		_:
			assert(false, "Update me")

func _on_pressed() -> void:
	if !GlobalVariables.logged_in:
		get_popup().hide()
		if GlobalVariables.session_not_found:
			open_login_screen.emit()
