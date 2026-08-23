extends Object
class_name ExtraFeatures

## Emitted when this object is ready to be freed.
signal finished

var error_life_time: float = 5
var error_fade_time: float = 1

var error_tween: Tween
func error(message: String, label: Control):
	if error_tween and error_tween.is_running():
		error_tween.kill()
	label.modulate.a = 1
	label.text = message
	error_tween = label.create_tween()
	error_tween.tween_property(label, "modulate:a", 1, error_life_time)
	error_tween.tween_property(label, "modulate:a", 0, error_fade_time)
	await error_tween.finished
	finished.emit()
