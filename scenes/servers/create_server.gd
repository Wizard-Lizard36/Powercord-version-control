extends Panel

const MAX_SERVERS: int = 10

signal create_server(server_name: String, private: bool)

@export var server_name_prompt: LineEdit
@export var private_server: CheckButton
@export var error_label: Label

func get_owned_server_count() -> int:
	var output: int = 0
	for server in await Talo.channels.get_subscribed_channels():
		if server.owner_alias.id == Talo.current_alias.id:
			output += 1
	return output

func _on_x_pressed() -> void:
	queue_free()

var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_confirm_pressed() -> void:
	if !server_name_prompt.text == server_name_prompt.text.validate_node_name():
		error_generator.error("Server name may not contain (., :, @, /, \", or %).", error_label)
		return
	if await get_owned_server_count() >= MAX_SERVERS:
		error_generator.error("You can only have a maximum of ten servers.", error_label)
		return
	
	create_server.emit(server_name_prompt.text, private_server.button_pressed)
	queue_free()
