extends TaloLoadable
class_name FriendsSave

@export var friends: Array[String] = []


func register_fields() -> void:
	register_field("friends", friends)

func on_loaded(data: Dictionary) -> void:
	if handle_destroyed(data):
		return
	friends = data.get("friends", [])
