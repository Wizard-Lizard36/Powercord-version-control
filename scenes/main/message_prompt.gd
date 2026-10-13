extends TextEdit

signal send_message(text: String)

@export var message_error: AcceptDialog

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("send_message"):
		if !Input.is_action_pressed("ui_escape_newline"):
			accept_event()
			if text.length() <= GlobalVariables.MAX_MESSAGE_LENGTH:
				if GlobalVariables.logged_in:
					send_message.emit(text)
					text = ""
			else:
				message_error.dialog_text = message_error.dialog_text.replace("[size]", str(GlobalVariables.MAX_MESSAGE_LENGTH))
				message_error.popup_centered()
