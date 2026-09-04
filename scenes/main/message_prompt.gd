extends TextEdit

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if !Input.is_action_pressed(""):
			pass
