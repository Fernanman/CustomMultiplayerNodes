## Custom multiplayer spawner.
##
## A custom multiplayer spawner that uses RPC's to spawn
## nodes on a tree. Can choose which peers to spawn the nodes on.

@icon("res://icons/custom_spawner.png")
class_name CustomSpawner
extends Node

signal spawned(node: Node) 	
signal despawned(node: Node)

@export var spawn_path: NodePath
@export var spawn_limit: int
@export var auto_spawn_list: PackedStringArray

## The function that instantiates the scene or node.
var instantiate_function: Callable
## The function that determines what data is important and should be extracted
## from the scene / node. This is used by spawn_all and can be used by spawn's data parameter.
var extract_data_function: Callable
## Array for the authority to keep track of all the scenes / nodes
## spawned by this node and the peers that have this node spawned as well.
var spawned_nodes: Array = []

func _ready():
	if self.has_node(self.spawn_path) and self.is_multiplayer_authority():
		self.get_node(self.spawn_path).child_exiting_tree.connect(self.call_free)
		self.get_node(self.spawn_path).child_entered_tree.connect(self.spawn_spawnable_scenes)

	if not self.is_multiplayer_authority():
		self.ask_spawn()

func _process(_delta):
	if self.is_multiplayer_authority() and Input.is_action_just_pressed('ui_accept'):
		self.clear_spawnable_scene()

## Adds the scene / node to the tree at the spawner's current spawn path.
## Returns true on succuess and false if the node was not added to tree.
func _add_scene_to_tree(node: Node) -> bool:
	var spawner_node = self.get_node(self.spawn_path)

	if spawner_node:
		if not spawner_node.has_node(node.get_name() as String):
			spawner_node.add_child(node, true)
			return true

		return false
		
	return false


## Spawns the node on both the authority and clients currently connected. 
## Must have the same node path on authority and client to work.
## Only the multiplayer authority can call this function succuessfully.
## data -- data used to spawn the node.
## ids -- list of unique ids to spawn the node on. Empty spawns the scene on every connected client.
func spawn(data: Variant=null, ids: Array=[]):
	if self.is_multiplayer_authority():
		var node = self.instantiate_function.call(data)
		self._add_scene_to_tree(node)
		self.spawned_nodes.append(node)
		
		if len(ids) == 0:
			spawn_clientside.rpc(data)
		else:
			for uid in ids:
				spawn_clientside.rpc_id(uid, data)

## Spawns the all of the peviously spawned nodes on the peer with the given id.
## Must have set the extract_data_function. 
func spawn_others(id: int):
	if self.is_multiplayer_authority() and self.extract_data_function:
		for node in self.spawned_nodes:
			var data = self.extract_data_function.call(node)
			
			if data:
				spawn_clientside.rpc_id(id, data)
			else:
				print("Could not spawn on peers: Data null")

## Asks the server to spawn pre existing spawned nodes.
func ask_spawn():
	grant_spawn.rpc_id(1)


#region Getters / Setters

## Sets the instance function for the spawner. The instance function
## should return a node given the data parameter.
func set_instantiate_function(instantiate_function_: Callable):
	self.instantiate_function = instantiate_function_

func get_instantiate_function() -> Callable:
	return self.instantiate_function

func set_extract_data_function(extract_data_function_: Callable):
	self.extract_data_function = extract_data_function_

func get_extract_data_function() -> Callable:
	return self.extract_data_function

func set_spawn_limit(value: int):
	self.spawn_limit = value

func get_spawn_limit() -> int:
	return self.spawn_limit

func set_spawn_path(value: NodePath):
	self.spawn_path = value

func get_spawn_path() -> NodePath:
	return self.spawn_path

#endregion

#region MultiplayerSpawner functions

## Adds a spawnable scene path to the auto spawn list if the path is valid.
func add_spawnable_scene(path: String):
	if ResourceLoader.exists(path):
		self.auto_spawn_list.append(path)

## Despawns all spawnable scenes spawned by this node by freeing them.
## May only be called by the authority.
func clear_spawnable_scene():
	if self.is_multiplayer_authority():
		for node in self.spawned_nodes:
			if node: node.queue_free()


## Returns the path the spawnable scene by index.
func get_spawnable_scene(index: int):
	return self.auto_spawn_list[index]

## Returns the length of the auto spawn list.
func get_spawnable_scene_count() -> int:
	return len(self.auto_spawn_list)

#endregion

#region Singal functions

## Calls free on the clients that have this node in their scene tree.
func call_free(node: Node):
	if node in self.spawned_nodes:
		free_remote.rpc(node.get_path())

		self.spawned_nodes.erase(node)

## Spawns spawnable scenes in the spawnable scenes list if one is added to a child of the spawn_path node that was not 
## spawned by this node.
func spawn_spawnable_scenes(node: Node):
	if not node in self.spawned_nodes and self.is_multiplayer_authority():
		for path in self.auto_spawn_list:
			var resource = load(path)
			var node_script = node.get_script()

			if resource is GDScript and node_script == resource \
			or resource is PackedScene and resource.instantiate().get_script() == node_script:
				var data = self.extract_data_function.call(node)
				self.spawned_nodes.append(node)
				spawn_clientside.rpc(data)

#endregion


#region RPCs

## Spawns the nodes on the client side.
@rpc("authority", "call_remote", "reliable", 0)
func spawn_clientside(data: Variant=null):
	self._add_scene_to_tree(self.instantiate_function.call(data))
	self.spawned.emit()

## Frees a node on all remote branches.
@rpc("authority", "call_remote", "reliable", 0)
func free_remote(path: NodePath):
	self.get_node(path).free()
	self.despawned.emit()

## Grants the request to spawn previous nodes on the requested client.
@rpc("any_peer", "call_remote", "reliable", 0)
func grant_spawn():
	self.spawn_others(multiplayer.get_remote_sender_id())

#endregion
