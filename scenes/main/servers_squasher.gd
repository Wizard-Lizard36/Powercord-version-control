extends HSplitContainer

var servers: Array[TaloChannel] = []
var server_nodes: Array[Button]

@export var server_list: VBoxContainer
@export var button_group: ButtonGroup

func _ready() -> void:
	if !Talo.has_identity():
		await Talo.players.identified
	await update_servers()
	update_server_list()

## Sets servers to the user's subscribed channels.
func update_servers() -> Array[TaloChannel]:
	var options: ChannelsAPI.GetSubscribedChannelsOptions = Talo.channels.GetSubscribedChannelsOptions.new()
	servers = await Talo.channels.get_subscribed_channels(options)
	return servers

func update_server_list() -> void:
	while server_nodes.size() > 0:
		server_nodes.pop_back().queue_free()
	for server: TaloChannel in servers:
		var button: Button = Button.new()
		button.add_theme_font_size_override("font_size", 32)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD
		button.toggle_mode = true
		button.button_group = button_group
		button.text = server.name
		server_list.add_child(button)
