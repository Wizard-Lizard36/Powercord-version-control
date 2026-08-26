extends Node

signal saves_loaded
signal save_chosen
signal save_fully_loaded

enum SaveType {
	LATEST = 0,
	CURRENT = 1,
}

var save_type: SaveType = SaveType.LATEST

func _ready() -> void:
	Talo.saves.saves_loaded.connect(_saves_loaded)
	Talo.saves.save_chosen.connect(_save_chosen)
	Talo.saves.save_loading_completed.connect(_save_fully_loaded)

# Just in case something forgot to save.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_CRASH:
		await save_to_latest()
		get_tree().quit()

func load_latest():
	if !Talo.has_identity():
		await Talo.players.identified
	save_type = SaveType.LATEST
	Talo.saves.choose_save((await Talo.saves.get_saves())[0])
	

func save_to_latest():
	save_type = SaveType.LATEST
	var saves: Array[TaloGameSave] = await Talo.saves.get_saves()
	if saves.size() <= 0:
		await Talo.saves.create_save("save")
		await save_to_latest()
	else:
		Talo.saves.choose_save(Talo.saves.latest, false)
		await Talo.saves.update_current_save()

func _saves_loaded() -> void:
	saves_loaded.emit()

func _save_chosen() -> void:
	save_chosen.emit()

func _save_fully_loaded() -> void:
	save_fully_loaded.emit()
