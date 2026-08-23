extends Panel

var confirmation_player_name: String = ""

@export var error_label: Label

func _on_resend_meta_clicked(meta: Variant) -> void:
	if str(meta) == "resend":
		SilentWolf.Auth.resend_conf_code(confirmation_player_name)
