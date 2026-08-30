extends HSplitContainer

var servers: Dictionary[String, TaloChannel] = {}
var server_nodes: Array[Button]
var messages: Dictionary[TaloChannel, Dictionary] = {}


@export var server_list: VBoxContainer
@export var message_list: VBoxContainer

@export var button_group: ButtonGroup

func _ready() -> void:
	if !Talo.has_identity():
		await Talo.players.identified
	await update_servers()
	update_server_list()

func _on_server_pressed(server: Button) -> void:
	var server_name: String = server.name
	

## Sets servers to the user's subscribed channels.
func update_servers() -> Dictionary[String, TaloChannel]:
	var options: ChannelsAPI.GetSubscribedChannelsOptions = Talo.channels.GetSubscribedChannelsOptions.new()
	servers.clear()
	for server in (await Talo.channels.get_subscribed_channels(options)):
		servers[server.name] = server
	return servers

func update_server_list() -> void:
	while server_nodes.size() > 0:
		server_nodes.pop_back().queue_free()
	for server: TaloChannel in servers.values():
		var button: Button = Button.new()
		button.add_theme_font_size_override("font_size", 32)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD
		button.toggle_mode = true
		button.button_group = button_group
		button.text = server.name
		server_list.add_child(button)
