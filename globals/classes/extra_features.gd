extends Object
class_name ExtraFeatures

## Emitted when this object is ready to be freed.
signal finished

var error_life_time: float = 5
var error_fade_time: float = 1

var error_tween: Tween
## Makes "output_label"'s text property equal "message" and then fades it over time using modulate.
func error(message: String, output_label: Control):
	if error_tween and error_tween.is_running():
		error_tween.kill()
	output_label.modulate.a = 1
	output_label.text = message
	error_tween = output_label.create_tween()
	error_tween.tween_property(output_label, "modulate:a", 1, error_life_time)
	error_tween.tween_property(output_label, "modulate:a", 0, error_fade_time)
	await error_tween.finished
	finished.emit()
