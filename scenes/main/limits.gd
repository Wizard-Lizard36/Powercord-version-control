extends TaloLoadable
class_name LimitsSave

@export var limits: Dictionary = {
		"images" : 0,
}

func register_fields() -> void:
	register_field("limits", limits)

func on_loaded(data: Dictionary) -> void:
	if handle_destroyed(data):
		return
	var new_limits: Dictionary = data.get("limits", {})
	for new_limit: Variant in new_limits.keys():
		limits[new_limit] = new_limits[new_limit]
