extends Panel

signal create_server(server_name: String, private: bool)

@export var server_name_prompt: LineEdit
@export var private_server: CheckButton
@export var error_label: Label


func _on_x_pressed() -> void:
	queue_free()

var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_confirm_pressed() -> void:
	if server_name_prompt.text == server_name_prompt.text.validate_node_name():
		create_server.emit(server_name_prompt.text, private_server.button_pressed)
	else:
		error_generator.error("Server name may not contain (., :, @, /, \", or %).", error_label)
