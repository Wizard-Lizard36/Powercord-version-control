extends TaloLoadable
class_name FriendsSave

@export var friends: Array[String] = []

func _ready() -> void:
	super()
	Internet.friend_added.connect(_friend_added)

func register_fields() -> void:
	register_field("friends", friends)

func on_loaded(data: Dictionary) -> void:
	if handle_destroyed(data):
		return
	friends = data.get("friends", [])
	for username in friends:
		Internet.friend_loaded.emit(username)

func _friend_added(username: String) -> void:
	friends.append(username)
