extends TabContainer


func generate_message_data(message: String) -> Dictionary:
	return {
			"text" : message,
			"sender" : Talo.current_alias.display_name,
			}

func send_message(server: TaloChannel, message: String) -> void:
	Talo.channels.send_message(server.id, message)
	
	var message_datas: Array[String] = server.get_prop_array(GlobalVariables.MESSAGES_PROP_KEY)
	message_datas.append(generate_message_data(message))
	server.set_prop_array(GlobalVariables.MESSAGES_PROP_KEY, message_datas)


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
	var message_vbox: VBoxContainer = VBoxContainer.new()
	var sender_button: Button = Button.new()
	sender_button.text = message_data.sender
	sender_button.flat = true
	sender_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	sender_button.expand_icon = true
	
	var message_body: RichTextLabel = RichTextLabel.new()
	message_body.text = message_data.text
	message_body.fit_content = true
	ExtraFeatures.set_all_font_sizes(message_body, GlobalVariables.MESSAGE_FONT_SIZE)
	add_child(message_vbox)
	message_vbox.add_child(sender_button)
	message_vbox.add_child(message_body)
	
	var server_vbox: VBoxContainer
	for child in get_children():
		if child.name == server.name:
			server_vbox = child
	if server_vbox:
		server_vbox.add_child(message_vbox)

func clear_messages(server_name: String) -> void:
	for server_node in get_children():
		if server_node.name == server_name:
			for server_child in server_node.get_children():
				server_child.queue_free()

func load_messages(server: TaloChannel) -> void:
	clear_messages(server.name)
	
	var properties: Array[String] = server.get_prop_array(GlobalVariables.MESSAGES_PROP_KEY)
	
	for property in properties:
		var message_data: Dictionary = decode_property(property)
		add_message(server, message_data)


func show_server(server_name: String) -> void:
	for child_number in range(get_child_count()):
		if get_child(child_number).name == server_name:
			current_tab = child_number

func decode_property(property: String) -> Dictionary:
	return str_to_var(property) if str_to_var(property) is Dictionary else {}
