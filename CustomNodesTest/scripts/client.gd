## Client class that houses the ENet Multiplayer peer.
##
## Client connects to the server and is sent updates. Acknowledges player and 
## environment interactions via the server. Instantiates a new TCP chat client.

class_name Client
extends Node

var peer
var port: int
var server_ip: String

## The unique id of this client.
var uid: int
# Same as using 'multiplayer' variable but I like explictly stating it
var multiplayer_api: MultiplayerAPI


func _init(port_: int, server_ip_: String, compression_: int):
	# Node paths must be the same for RPCs to work. 
	self.set_name("NetworkConnection")
	self.uid = 0
	self.port = port_
	self.server_ip = server_ip_
	self.peer = ENetMultiplayerPeer.new()

	var error = self.peer.create_client(self.server_ip, self.port)
	if error:
		print("Creating ENet client failed: ", error)
		return
	
	self.peer.get_host().compress(compression_)

func _ready():
	# Can only call the multiplayer api after it's entered the scene tree
	self.multiplayer_api = self.get_tree().get_multiplayer()

	self.multiplayer_api.set_multiplayer_peer(self.peer)

	# These keep track of all the palyers that connect.
	self.multiplayer_api.connection_failed.connect(_on_connection_failed)
	self.multiplayer_api.connected_to_server.connect(_on_connect_to_server)
	self.multiplayer_api.server_disconnected.connect(_on_server_disconnect)
	self.multiplayer_api.peer_connected.connect(_on_peer_connect)
	self.multiplayer_api.peer_disconnected.connect(_on_peer_disconnect)
			
	self.uid = self.multiplayer_api.get_unique_id()

func _process(_delta):
	pass

func _on_connect_to_server():
	# print("ENet Client: Successfully connected to server.")
	pass

func _on_connection_failed():
	print("ENet Client: Connection with server failed.")

func _on_peer_connect(id: int):
	if id == 1:
		# print("ENet Client: Player connected to server.")
		pass
	else:
		# print("ENet Client: New peer connected with id - ", id)
		pass

func _on_peer_disconnect(_id: int):
	# print("ENet Client: Peer disconnected with id - ", id)
	pass

func _on_server_disconnect():
	# print("ENet Client: Disconnected from server.")
	pass

