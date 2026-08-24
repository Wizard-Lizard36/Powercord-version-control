extends Node

signal connection_changed(online: bool)

const IMAGE_QUALITY = 0.75
const INTERNET_CHECK_INTERVAL = 3

var online: bool = false:
	set(connection):
		online = connection
		connection_changed.emit(online)

var internet_timer: Timer = Timer.new()
var internet_checker: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	internet_timer.autostart = true
	internet_timer.wait_time = INTERNET_CHECK_INTERVAL
	add_child(internet_timer)
	add_child(internet_checker)


func _on_internet_timer_timeout() -> void:
	if _check_for_internet() == false:
		online = false

## Returning true DOES NOT necessarily mean that the request was successful. Conflictingly
func _check_for_internet() -> bool:
	var url = "https://wizard-lizard36.github.io/Power-cord/" 
	var error = internet_checker.request(url)
	
	if error != OK:
		print("Internet request failed.")
		return false
	return true

func _request_completed(result: int, response_code: int, _headers):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		online = true
	else:
		online = false
