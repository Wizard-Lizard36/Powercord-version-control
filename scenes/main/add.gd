extends Button

const MAX_IMAGES = 1

var popup: PopupMenu
var file_opener: FileDialog

@export var message_list: TabContainer
@export var limits: LimitsSave

func _on_pressed() -> void:
	if popup:
		popup.queue_free()
	popup = PopupMenu.new()
	popup.id_pressed.connect(_popup_button_pressed)
	popup.add_item("Image")
	add_child(popup)
	popup.popup(Rect2i(Vector2i(roundi(global_position.x), roundi(global_position.y) - popup.size.y), popup.size))

func _popup_button_pressed(id: int) -> void:
	popup.queue_free()
	match id:
		0:
			if limits.limits["images"] < MAX_IMAGES:
				open_file()
			else:
				var youve_hit_your_limit: AcceptDialog = AcceptDialog.new()
				youve_hit_your_limit.title = "Sorry..."
				youve_hit_your_limit.dialog_text = "You have hit your image limit >:)"
				youve_hit_your_limit.canceled.connect(youve_hit_your_limit.queue_free)
				youve_hit_your_limit.confirmed.connect(youve_hit_your_limit.queue_free)
				add_child(youve_hit_your_limit)
				youve_hit_your_limit.popup_centered()
		_:
			assert(false, "UPDATE THIS!!!")


func open_file() -> void:
	if file_opener:
		file_opener.queue_free()
	file_opener = FileDialog.new()
	file_opener.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_opener.add_filter("*.png, *.jpg, *.svg, *.webp", "Images", "image/png, image/jpeg, image/svg, image/webp")
	file_opener.file_selected.connect(_file_selected)
	add_child(file_opener)
	file_opener.popup_centered()

func _file_selected(path: String) -> void:
	message_list.image_to_add = Image.load_from_file(path)
