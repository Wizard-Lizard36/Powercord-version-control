extends Panel

@export var friends_list: VBoxContainer
@export var add_popup: PopupPanel
@export var username_prompt: LineEdit
@export var error_label: Label
@export var invite_popup: PopupPanel
@export var invite_server_list: VBoxContainer

var friend_to_invite: String = "(╯°□°)╯︵ ┻━┻ \n :3"

func _ready() -> void:
	update_list()


func update_list() -> void:
	for i in range(Internet.friends.size() - friends_list.get_child_count()):
		var new_button: Button = Button.new()
		new_button.pressed.connect(_on_friend_alias_pressed.bind(new_button))
		friends_list.add_child(new_button)
	for child_number in range(friends_list.get_child_count()):
		var child: Node = friends_list.get_child(child_number)
		if child is Button:
			if Internet.friends.size() > child_number:
				child.text = Internet.friends[child_number]
			else:
				child.queue_free()

func _on_search_bar_text_changed(new_text: String) -> void:
	var friends: Array[Button]
	for child in friends_list.get_children():
		if child is Button:
			friends.append(child)
			#TODO Make search bar work, probably when fuzzy search comes out?


func _on_friend_alias_pressed(friend_button: Button) -> void:
	friend_to_invite = friend_button.text
	for server in invite_server_list.get_children():
		server.queue_free()
	for server_name: String in Servers.servers.keys():
		if Servers.servers[server_name].owner_alias.display_name != Talo.current_alias.display_name:
			continue
		var server_button: Button = Button.new()
		server_button.text = server_name
		server_button.pressed.connect(_server_pressed.bind(Servers.servers[server_name]))
		invite_server_list.add_child(server_button)
	invite_popup.popup()

func _server_pressed(server: TaloChannel) -> void:
	var search_page: PlayersAPI.SearchPage = await Talo.players.search(friend_to_invite)
	Talo.channels.invite(server.id, search_page.players[0].aliases[0].id)
	invite_popup.hide()

func _on_x_pressed() -> void:
	queue_free()

func _on_invite_x_pressed() -> void:
	invite_popup.hide()

func _on_add_friend_pressed() -> void:
	add_popup.popup_centered(Vector2(300, 140))


var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_confirm_pressed() -> void:
	var alias: String = username_prompt.text
	var res: PlayersAPI.SearchPage = await Talo.players.search(alias)
	if res.count > 0:
		Internet.friend_added.emit(alias)
		OnlineSaves.save_to_latest()
		add_popup.queue_free()
		await get_tree().create_timer(0.5).timeout
		update_list()
	else:
		error_generator.error("Entered username does not exist.", error_label)
