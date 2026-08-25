extends Panel

@export var friends_list: VBoxContainer
@export var add_popup: PopupPanel
@export var username_prompt: LineEdit
@export var friends_save: FriendsSave
@export var error_label: Label

func update_list() -> void:
	for i in range(friends_save.friends.size() - friends_list.get_child_count()):
		var new_button: Button = Button.new()
		new_button.pressed.connect(_on_friend_alias_pressed.bind(new_button))
		friends_list.add_child(new_button)
	for child_number in range(friends_list.get_child_count()):
		var child: Node = friends_list.get_child(child_number)
		if child is Button:
			if friends_save.friends.size() > child_number:
				child.text = friends_save.friends[child_number]
			else:
				child.queue_free()


func _on_friend_alias_pressed(friend_button: Button):
	var friend_alias: String = friend_button.text
	friend_alias = friend_alias


func _on_x_pressed() -> void:
	queue_free()


func _on_add_friend_pressed() -> void:
	add_popup.popup_centered(Vector2(300, 140))


var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_confirm_pressed() -> void:
	var alias: String = username_prompt.text
	var res: PlayersAPI.SearchPage = await Talo.players.search(alias)
	if res.count > 0:
		friends_save.friends.append(alias)
		OnlineSaves.save_to_latest()
		update_list()
		add_popup.queue_free()
	else:
		error_generator.error("Entered username does not exist.", error_label)
