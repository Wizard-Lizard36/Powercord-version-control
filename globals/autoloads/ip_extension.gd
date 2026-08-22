extends Node

var ip_address: String = "local_host"
var ip_fetched: bool = false:
	set(new_ip):
		ip_fetched = new_ip
		ip_just_fetched.emit()

signal ip_just_fetched

func _ready() -> void:
	var http_request: = HTTPRequest.new()
	add_child(http_request)
	# 1. Connect the completion signal to a handler function
	http_request.request_completed.connect(_on_request_completed)
	
	# 2. Call an external service to fetch the public IP address
	var error = http_request.request("https://api.ipify.org")
	if error != OK:
		print("An error occurred while making the HTTP request.")

# 3. Process the response when the server answers
func _on_request_completed(_result, response_code, _headers, body: PackedByteArray):
	if response_code == 200:
		var public_ip = body.get_string_from_utf8().strip_edges()
		print("Your Public IP is: ", public_ip)
		ip_address = public_ip
		ip_fetched = true
		ip_just_fetched.emit()
	else:
		print("Failed to fetch public IP. Response code: ", response_code)
