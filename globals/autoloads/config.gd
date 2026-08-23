extends Node

const CONFIG_PATH: String = "user://config.cfg"

const DEFAULT_CONFIG: Dictionary = {
	"QOL" : ["remember_me", false],
}


## Sets a value in the config.
func set_config_value(section: String, key: String, value: Variant):
	var writing: ConfigFile = ConfigFile.new()
	writing.set_value(section, key, value)
	writing.save(CONFIG_PATH)

func get_config_value(section: String, key: String) -> Variant:
	if !FileAccess.file_exists(CONFIG_PATH):
		var writing: ConfigFile = ConfigFile.new()
		for default_key in DEFAULT_CONFIG.keys():
			writing.set_value(default_key, DEFAULT_CONFIG[default_key][0], DEFAULT_CONFIG[default_key][1])
		writing.save(CONFIG_PATH)
	
	var reading: ConfigFile = ConfigFile.new()
	reading.load(CONFIG_PATH)
	return reading.get_value(section, key)
