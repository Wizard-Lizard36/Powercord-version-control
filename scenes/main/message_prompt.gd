extends TextEdit

signal send_message(text: String)

@export var length_error: AcceptDialog

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("send_message"):
		if !Input.is_action_pressed("ui_escape_newline"):
			accept_event()
			if text.length() <= 450:
				send_message.emit(text)
				text = ""
			else:
				length_error.popup_centered()
