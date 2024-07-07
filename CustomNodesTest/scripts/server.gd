## Server class that houses the ENet Multiplayer authority.
##
## Server that keeps track of players and their associated names. Keeps track
## accepts new connections and adds them to the server. Instantiates a new TCP
## chat server.

class_name Server
extends Node

## The peer connection
var peer: ENetMultiplayerPeer
## The port that the server listens on
var port: int
## The maximum amount of players that can be connected to the server simultaneously
var max_clients: int
## Array for keeping track of players
var players: Array = []
# Same as using 'multiplayer' variable but I like explictly stating it
var multiplayer_api: MultiplayerAPI
# Players node
var players_node: Node2D

var spawner: CustomSpawner

func _init(port_: int, max_clients_: int, compression_: int):
	self.set_name("NetworkConnection")
	self.port = port_
	self.max_clients = max_clients_

	self.peer = ENetMultiplayerPeer.new()
	
	var error = self.peer.create_server(self.port, self.max_clients)
	if error != OK:
		print("Creating ENet server failed: ", error)
		return

	# Sets the binded ip ot the wildcard, which binds to all available interfaces.
	self.peer.set_bind_ip("*")

	# Sets the compression method. Don't send packets > 4KB using COMPRESS_RANGE_CODER
	self.peer.get_host().compress(compression_)


func _ready():
	self.players_node = self.get_parent().get_node("Players")
	self.spawner = self.get_parent().get_node("CustomPlayerSpawner")
	self.multiplayer_api = self.get_tree().get_multiplayer()

	self.multiplayer_api.peer_connected.connect(_on_player_connect)
	self.multiplayer_api.peer_disconnected.connect(_on_player_disconnect)

	self.multiplayer_api.set_multiplayer_peer(self.peer)


func _process(_delta: float):
	pass


func _add_player_spawn(id: int, spawn_point:Vector2=Vector2(320, 240)):
	self.spawner.spawn([id, spawn_point])

func _add_player_spawnable_scene(id: int, spawn_point:Vector2=Vector2(320, 240)):
	var new_player = preload("res://scenes/sync_player.tscn").instantiate()
	new_player.set_name(str(id))
	new_player.set_global_position(spawn_point)
	new_player.get_node("Inputs").set_multiplayer_authority(id)

	self.players_node.add_child(new_player)

## Removes the player to the scene, causing the player to despawn on every other peer.
## Only called whne a player disconnects.
func _remove_player(_id: int):
	pass
	

 ## Sets a player's username to empty on connection and waits to receive their username to be added to the game.
func _on_player_connect(id: int):
	print('Player with id ', str(id) , ' connected')
	# self._add_player_spawn(id)
	self._add_player_spawnable_scene(id)

func _on_player_disconnect(id: int):
	print('Player with id ', str(id) , ' disconnected')
