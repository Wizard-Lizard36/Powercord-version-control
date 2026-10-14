extends Button
class_name SenderButton

var icon_size: int = 320

func _ready() -> void:
	self.icon = preload("uid://iy5o4jo6kb5e")
	self.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	self.flat = true
	self.alignment = HORIZONTAL_ALIGNMENT_LEFT
	self.expand_icon = true
	self.custom_minimum_size.x = size.x + icon_size
	self.add_theme_font_size_override("font_size", GlobalVariables.MESSAGE_SENDER_FONT_SIZE)
