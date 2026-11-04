extends Node

signal _gif_search_complete(web_pictures: Array[Image])
signal _webp_found(webp: Image)

# Very stealable, but who honestly cares at this point; it's not like i'm enterprise or anything.
const API_KEY: String = "z2FLjwpRcIdbyuO9TKT1ObWL9mdxdlPK"

const PossibleRequests: Dictionary[String, String] = {
	SEARCH = "search",
}

var http_request: HTTPRequest
var webp_request: HTTPRequest

var requests: Array[String] = []


func _ready() -> void:
	http_request = HTTPRequest.new()
	http_request.request_completed.connect(_on_http_request_complete)
	add_child(http_request)
	
	webp_request = HTTPRequest.new()
	webp_request.request_completed.connect(_on_webp_request_complete)
	add_child(webp_request)
	
	print(await search_for_gifs("ohio respect", 5))

## Confusingly, this function does not actually returns gifs, but animated webp (godot does not support gifs). 
func search_for_gifs(search_term: String, max_results: int = 25) -> Array[Image]:
	print(http_request.request("https://api.giphy.com/v1/gifs/search?api_key=%s&q=%s&limit=%s" % [API_KEY, search_term.uri_encode(), str(max_results).uri_encode()]))
	requests.append(PossibleRequests.SEARCH)
	return await _gif_search_complete

func _on_http_request_complete(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var request: String = requests.pop_front()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("result: " + str(result))
		_gif_search_complete.emit([])
		return
	
	if response_code != 200:
		push_error("Request failed with response code: %s" % str(response_code))
		_gif_search_complete.emit([])
		return
	
	
	var unparsed_json: String = body.get_string_from_utf8()
	var parsed_json: Dictionary = JSON.parse_string(unparsed_json)
	if request == PossibleRequests.SEARCH:
		var output: Array[Image] = []
		for gif_data: Dictionary in parsed_json["data"]:
			var webp_url: String = gif_data["images"]["original"]["webp"]
			webp_request.request("https://i.giphy.com/" + webp_url.split("/")[-2] + ".webp")
			output.append(await _webp_found)
		_gif_search_complete.emit(output)

func _on_webp_request_complete(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Webp request failed with result: " + str(result))
		_webp_found.emit(null)
		return
	
	if response_code != 200:
		push_error("Webp Request failed with response code: %s" % str(response_code))
		_webp_found.emit(null)
		return
	
	var output: Image = Image.new()
	
	output.load_webp_from_buffer(body)
	_webp_found.emit(output)
