extends TabContainer


func send_message(server: TaloChannel) -> bool:
	return false

func load_server(server: TaloChannel) -> void:
	
	for child in get_children():
		if child.name == server.name:
			return
	
	var message_list: VBoxContainer = VBoxContainer.new()
	add_child(message_list)
	message_list.name = server.name
	
	load_messages(server)

func add_message(server: TaloChannel, message: Dictionary) -> void:
	var message_vbox: VBoxContainer = VBoxContainer.new()
	var sender_button: Button = Button.new()
	sender_button.text = message.sender
	sender_button.flat = true
	sender_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	sender_button.expand_icon = true
	
	var message_body: RichTextLabel = RichTextLabel.new()
	message_body.text = message.text
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


func load_messages(server: TaloChannel) -> void:
	
	var properties: Array[String] = server.get_prop_array(GlobalVariables.MESSAGES_PROP_KEY)
	
	for property in properties:
		var message: Dictionary = decode_property(property)

func decode_property(property: String) -> Dictionary:
	return str_to_var(property) if str_to_var(property) is Dictionary else {}
