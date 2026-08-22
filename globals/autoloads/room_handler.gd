extends Node

const PORT = 1432
const MAX_CLIENTS = 32
const ADDRESS = "wss://Wizard-Lizard36.github.io/Power-cord"

var ip_address: String  = "local_host"

signal client_joined(id: int)


func host_lobby() -> Error:
	ip_address = IPExtension.ip_address
	
	var peer: = WebSocketMultiplayerPeer.new()
	
	var upnp_success: bool = setup_upnp(PORT)
	if upnp_success:
		print("UPnP Succeeded.")
	else:
		print("UPnP Failed. Joining is likely to fail.")
	
	var err: Error = peer.create_server(PORT)
	if !err:
		multiplayer.multiplayer_peer = peer
		peer.peer_connected.connect(_client_joined)
	return err

func join_lobby() -> Error:
	ip_address = IPExtension.ip_address
	
	var peer: = WebSocketMultiplayerPeer.new()
	var err: Error = peer.create_client(ip_address)
	if !err:
		multiplayer.multiplayer_peer = peer
	return err

func setup_upnp(port: int) -> bool:
	if !ClassDB.can_instantiate("UPNP"):
		return false
	
	var upnp: UPNP = UPNP.new()
	
	var discover_result: int = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		return false
	
	if upnp.get_gateway() == null:
		return false
	
	var map_result = upnp.add_port_mapping(port, 0, "", "TCP", roundi(86400.0 / 24))
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		return false
	
	print("External IP:", upnp.query_external_address())
	return true

func _client_joined(id: int):
	client_joined.emit(id)
