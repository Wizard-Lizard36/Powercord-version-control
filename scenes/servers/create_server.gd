extends Panel

signal create_server(server_name: String, private: bool)

@export var server_name_prompt: LineEdit
@export var private_server: CheckButton


func _on_x_pressed() -> void:
	queue_free()


func _on_confirm_pressed() -> void:
	create_server.emit(server_name_prompt.text, private_server.button_pressed)
