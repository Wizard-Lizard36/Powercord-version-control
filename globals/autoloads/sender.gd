extends Node

const IMAGE_QUALITY = 0.75
const INTERNET_CHECK_INTERVAL = 3

const Keys: Dictionary = {
	Messages = "messages",
	Recipient = "recipient",
	Message = "message",
	Attachments = "attachments",
	AttachmentImage = "image"
}

var has_internet: bool = false

var internet_timer: Timer = Timer.new()
var internet_checker: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	internet_timer.autostart = true
	internet_timer.wait_time = INTERNET_CHECK_INTERVAL
	add_child(internet_timer)
	add_child(internet_checker)



## Sends "message" to "recipient" with optional "image".
## Message is shown as being from "sender".
func send_message(sender: String, recipient: String, message: String, image: Image = null):
	pass

func _on_internet_timer_timeout() -> void:
	if _check_for_internet() == false:
		has_internet = false

## Returning true DOES NOT necessarily mean that the request was successful.
func _check_for_internet() -> bool:
	var url = "https://wizard-lizard36.github.io/Power-cord/" 
	var error = internet_checker.request(url)
	
	if error != OK:
		print("Internet request failed.")
		return false
	return true

func _request_completed(result: int, response_code: int, _headers):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		has_internet = true
	else:
		has_internet = false
