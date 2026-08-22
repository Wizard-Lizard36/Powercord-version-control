extends Control

@export var color_rect: ColorRect

var server: bool = false

func _ready() -> void:
	if !IPExtension.ip_fetched:
		await IPExtension.ip_just_fetched
	
	var err: Error = RoomHandler.join_lobby() if !server else ERR_LOCKED
	print(error_string(err) if !server else "Creating server...")
	if err != OK:
		color_rect.color = Color.RED
		if server:
			if RoomHandler.host_lobby() == OK:
				print("Server creation successful")
				color_rect.color = Color.GREEN
				RoomHandler.client_joined.connect(_client_joined)

func _client_joined(_id: int):
	print("Client joined successfully")
	color_rect.color = Color.BLUE
