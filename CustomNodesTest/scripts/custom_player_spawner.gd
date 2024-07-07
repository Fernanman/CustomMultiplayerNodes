## Node that spawns players.
##
## Multiplayer spawner sublcass for spawning players.

class_name CustomPlayerSpawner
extends CustomSpawner

const player_scene = preload("res://scenes/sync_player.tscn")


func _init():
	self.add_spawnable_scene("res://scripts/player.gd")
	self.set_instantiate_function(self._instantiate_player)
	self.set_extract_data_function(self._extract_player_data)

func _ready():
	super()
	multiplayer.connected_to_server.connect(self._acknowledge_connection)

func _extract_player_data(node: Node) -> Array:
	var ret = []
	if node is Player:
		ret.append((node.get_name() as String).to_int())
		ret.append(node.get_global_position())

	return ret


func _instantiate_player(data: Array) -> Player:
	if not (data is Array) or \
	not data.size() == 2 or \
	not (data[0] is int) or \
	not (data[1] is Vector2):
		print("Did not instantiate ", 
		data is Array, " ", data.size() == 2, " ",
		data[0] is int, " ", data[1] is Vector2)
		return null
	
	var new_player = self.player_scene.instantiate()

	var a = new_player.get_node("CustomSynchronizer")
	a.add_property('serverside_pos')

	new_player.get_child(3).set_multiplayer_authority(data[0])
	new_player.set_name(str(data[0]))
	new_player.set_global_position(data[1])
	new_player.set_serverside_pos(data[1])

	return new_player

func _acknowledge_connection():
	self.ask_spawn()
