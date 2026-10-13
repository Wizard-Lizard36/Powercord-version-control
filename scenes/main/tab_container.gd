extends TabContainer

const SENT_IMAGE_QUALITY = 0.5

signal set_current_server(server_name: String)
signal current_server_set

var current_server: TaloChannel

var loaded_messages: Dictionary[TaloChannel, Array]

@export var message_scroll_container: ScrollContainer
@export var limits: LimitsSave

var image_to_add: Image = null

func _ready() -> void:
	Talo.channels.channel_storage_props_updated.connect(_message_recieved)


const TARGET_IMAGE_SIZE: int = 1080

# Called when the node enters the scene tree for the first time.
func encode_image(image: Image) -> PackedStringArray:
	
	var image_size: Vector2i = image.get_size()
	
	var quotient: float = 0
	
	var x_bigger: bool = true if image_size.x > image_size.y else false
	
	if x_bigger:
		quotient = TARGET_IMAGE_SIZE / float(image_size.x)
		image.resize(TARGET_IMAGE_SIZE, int(image_size.y * quotient))
	else:
		quotient = TARGET_IMAGE_SIZE / float(image_size.y)
		image.resize(int(image_size.x * quotient), TARGET_IMAGE_SIZE)
	
	
	
	var buffer: PackedByteArray = image.save_webp_to_buffer(true, SENT_IMAGE_QUALITY)
	
	var start_string: String = var_to_str(buffer)
	
	var output_array: Array[String] = []
	
	while start_string.length() > 0:
		output_array.append(start_string.left(500))
		start_string = start_string.erase(0, 500)
	if output_array.size() > 1000:
		assert(false)
		push_error("Something seems broken here.")
		return []
	
	return output_array

## Decodes the image encoded as an [Array]\[[String]\].
## Returns null on failure.
func decode_image(data_array: PackedStringArray) -> Image:
	var end_string: String = ""
	for string in data_array:
		end_string += string
	
	var buffer: PackedByteArray = str_to_var(end_string)
	var loaded_image: Image = Image.new()
	var err: Error = loaded_image.load_webp_from_buffer(buffer)
	if !err:
		return loaded_image
	return null

func generate_message_data(message: String, image_data: PackedStringArray = []) -> Dictionary[String, String]:
	return {
			"text" : message,
			"sender" : Talo.current_alias.display_name,
			"time_sent" : str(Time.get_unix_time_from_system()),
			"image_id" : str(hash(image_data)) if image_data else "-1",
	}



func send_message(server: TaloChannel, message: String) -> void:
	var message_datas: Array[String] = []
	
	var talo_message_datas: Array[TaloChannelStorageProp] = await Talo.channels.get_storage_prop_array(server.id, GlobalVariables.MESSAGES_PROP_KEY, true)
	for talo_message_data in talo_message_datas:
		message_datas.append(talo_message_data.value)
	var message_data: Dictionary = generate_message_data(message, encode_image(image_to_add))
	message_datas.append(var_to_str(message_data))
	if str(message_data.image_id) != "-1":
		var typed_array: Array[String]
		typed_array.assign(encode_image(image_to_add))
		Talo.channels.set_storage_prop_array(current_server.id, str(message_data.image_id), typed_array)
		limits.limits["images"] += 1
		OnlineSaves.save_to_latest()
	
	Talo.channels.set_storage_prop_array(server.id, GlobalVariables.MESSAGES_PROP_KEY, message_datas)

func get_prop_value(prop: TaloChannelStorageProp) -> Variant:
	return prop.value

func get_message_datas(server: TaloChannel, bust_cache: bool = true) -> Array[Dictionary]:
	var message_datas: Array[Dictionary]
	message_datas.assign(loaded_messages[server] if loaded_messages.has(server) else [])
	if bust_cache:
		message_datas.clear()
	if message_datas.is_empty():
		var talo_message_datas: Array[TaloChannelStorageProp] = await Talo.channels.get_storage_prop_array(server.id, GlobalVariables.MESSAGES_PROP_KEY, true)
		for talo_message_data in talo_message_datas:
			message_datas.append(str_to_var(talo_message_data.value))
	return message_datas

func prop_array_to_string_array(prop_array: Array[TaloChannelStorageProp]) -> Array[String]:
	var strings: Array[String] = []
	for prop in prop_array:
		strings.append(prop.value)
	return strings

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
	if !loaded_messages.has(server):
		loaded_messages[server] = []
	loaded_messages[server].append(message_data)
	if !message_data.has("sender"):
		return
	var message_vbox: VBoxContainer = VBoxContainer.new()
	#var sender_hbox: HBoxContainer = HBoxContainer.new()
	var sender_button: SenderButton = SenderButton.new()
	var time_sent: RichTextLabel = RichTextLabel.new()
	time_sent.fit_content = true
	time_sent.autowrap_mode = TextServer.AUTOWRAP_OFF
	time_sent.text = message_data["time_sent"] if message_data.has("time_sent") else "Unknown"
	sender_button.text = message_data.sender
	
	var message_body: RichTextLabel = RichTextLabel.new()
	message_body.text = message_data.text
	message_body.fit_content = true
	
	ExtraFeatures.set_all_font_sizes(message_body, GlobalVariables.MESSAGE_FONT_SIZE)
	
	message_vbox.add_child(sender_button)
	#sender_hbox.add_child(time_sent)
	#message_vbox.add_child(sender_hbox)
	message_vbox.add_child(message_body)
	if message_data.has("image_id"):
		if str(message_data.image_id) != "-1":
			print(message_data.image_id)
			var image: Image = decode_image(PackedStringArray(prop_array_to_string_array(await Talo.channels.get_storage_prop_array(server.id, str(message_data.image_id), true))))
			var image_representation: TextureRect = TextureRect.new()
			image_representation.expand_mode = TextureRect.EXPAND_KEEP_SIZE
			image_representation.texture = ImageTexture.create_from_image(image)
			message_vbox.add_child(image_representation)
	
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
	
	var message_datas: Array[Dictionary] = await get_message_datas(server)
	for message_data in message_datas:
		await add_message(server, message_data)


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
