extends TabContainer

signal set_current_server(server_name: String)
signal current_server_set

var current_server: TaloChannel

@export var message_scroll_container: ScrollContainer

func _ready() -> void:
	Talo.channels.channel_storage_props_updated.connect(_message_recieved)

func generate_message_data(message: String) -> Dictionary:
	return {
			"text" : message,
			"sender" : Talo.current_alias.display_name,
			}


func send_message(server: TaloChannel, message: String) -> void:
	
	var talo_message_datas: Array[TaloChannelStorageProp] = await Talo.channels.get_storage_prop_array(server.id, GlobalVariables.MESSAGES_PROP_KEY, true)
	var message_datas: Array[String] = []
	for talo_message_data in talo_message_datas:
		message_datas.append(talo_message_data.value)
	message_datas.append(var_to_str(generate_message_data(message)))
	Talo.channels.set_storage_prop_array(server.id, GlobalVariables.MESSAGES_PROP_KEY, message_datas)



func load_server(server: TaloChannel) -> void:
	
	for child in get_children():
		if child.name == server.name:
			load_messages(server)
			return
	
	var message_list: VBoxContainer = VBoxContainer.new()
	add_child(message_list)
	message_list.name = server.name
	
	load_messages(server)


func add_message(server: TaloChannel, message_data: Dictionary) -> void:
	if !message_data.has("sender"):
		return
	var message_vbox: VBoxContainer = VBoxContainer.new()
	var sender_button: Button = Button.new()
	sender_button.text = message_data.sender
	sender_button.icon = preload("uid://iy5o4jo6kb5e")
	sender_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sender_button.flat = true
	sender_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	sender_button.expand_icon = true
	sender_button.add_theme_font_size_override("font_size", GlobalVariables.MESSAGE_SENDER_FONT_SIZE)
	
	var message_body: RichTextLabel = RichTextLabel.new()
	message_body.text = message_data.text
	message_body.fit_content = true
	ExtraFeatures.set_all_font_sizes(message_body, GlobalVariables.MESSAGE_FONT_SIZE)
	message_vbox.add_child(sender_button)
	message_vbox.add_child(message_body)
	
	var server_vbox: VBoxContainer
	for child in get_children():
		if child.name == server.name:
			server_vbox = child
	if server_vbox:
		server_vbox.add_child(message_vbox)
	
	var current_value: float = message_scroll_container.get_v_scroll_bar().max_value - message_scroll_container.get_v_scroll_bar().page
	if message_scroll_container.scroll_vertical == round(current_value):
		await get_tree().process_frame
		var new_value: float = message_scroll_container.get_v_scroll_bar().max_value - message_scroll_container.get_v_scroll_bar().page
		message_scroll_container.scroll_vertical = round(new_value)


func clear_messages(server_name: String) -> void:
	for server_node in get_children():
		if server_node.name == server_name:
			for server_child in server_node.get_children():
				server_child.queue_free()


func load_messages(server: TaloChannel) -> void:
	clear_messages(server.name)
	
	
	var properties: Array[TaloChannelStorageProp] = await Talo.channels.get_storage_prop_array(server.id, GlobalVariables.MESSAGES_PROP_KEY)
	var message_datas: Array[String] = []
	for property in properties:
		message_datas.append(property.value)
	for message_data in message_datas:
		var decoded_message_data: Dictionary = decode_property(message_data)
		add_message(server, decoded_message_data)


func show_server(server_name: String) -> void:
	for child_number in range(get_child_count()):
		if get_child(child_number).name == server_name:
			current_tab = child_number
			set_current_server.emit(server_name)


func decode_property(property: String) -> Dictionary:
	return str_to_var(property) if str_to_var(property) is Dictionary else {}

func _message_recieved(server: TaloChannel, upserted: Array[TaloChannelStorageProp], _deleted: Array[TaloChannelStorageProp]) -> void:
	if !upserted.is_empty():
		add_message(server, decode_property(upserted.back().value))

func _current_server_set() -> void:
	current_server_set.emit()


func _on_message_prompt_send_message(text: String) -> void:
	send_message(current_server, text)
