extends TabContainer




func send_message(server: TaloChannel) -> bool:
	return false

func load_server(server: TaloChannel) -> void:
	
	var message_list: VBoxContainer = VBoxContainer.new()
	add_child(message_list)
	message_list.name = server.name
	
	load_messages(server)

func add_message() -> void:
	var message_vbox: VBoxContainer = VBoxContainer.new()
	

func load_messages(server: TaloChannel) -> void:
	
	var properties: Array[String] = server.get_prop_array("messages")
	
	for property in properties:
		var message: Dictionary = decode_property(property)

func decode_property(property: String) -> Dictionary:
	return str_to_var(property) if str_to_var(property) is Dictionary else {}
