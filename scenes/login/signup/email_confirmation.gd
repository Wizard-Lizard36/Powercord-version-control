extends Panel

signal verify_complete(success: bool)

@export var error_label: Label
@export var code_prompt: LineEdit

var error_generator: ExtraFeatures = ExtraFeatures.new()
func _on_submit_pressed() -> void:
	var res: PlayerAuthAPI.PlayerAuthResult = await Talo.player_auth.verify(code_prompt.text)
	if !res.success:
		match res.error.code:
			TaloPlayerAuthError.ErrorCode.INVALID_CREDENTIALS:
				error_generator.error("Verification code is incorrect", error_label)
			_:
				error_generator.error(res.error.message, error_label)
		verify_complete.emit(false)
	else:
		OnlineSaves.load_latest()
		GlobalVariables.logged_in = true
		verify_complete.emit(true)
		queue_free()
