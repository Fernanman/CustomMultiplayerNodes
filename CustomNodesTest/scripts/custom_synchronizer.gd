## Custom multiplayer synchronizer.
##
## A custom multiplayer synchronizer that uses RPC's to synchronize
## nodes on a tree. 

@icon('res://icons/custom_synchronizer.png')
class_name CustomSynchronizer
extends Node

@export var root_path: NodePath
@export var properties: PackedStringArray

## Function that the process calls. Changes depending on if the root node exists.
var process_function: Callable

func _ready():
	if self.get_node(self.root_path):
		self.process_function = self._sync_function
	else:
		self.process_function = func(): pass        

## The function that synchronizes the nodes.
func _sync_function():
	if self.is_multiplayer_authority():
		var values = []
		var root_node = self.get_node(self.root_path)
		
		for prop in self.properties:
			values.append(root_node.get(prop))
		
		syncronize.rpc(values)

func _process(_delta):
	self.process_function.call()


## Checks if the root node of the synchnizer has the given property.
func has_property(property: String):
	return property in self.get_node(self.root_path)

## Adds the property name to the property list.
func add_property(property: String):
	if self.has_property(property) and property not in self.properties:
		self.properties.append(property)

#region RPCs

@rpc('authority', 'call_remote', 'unreliable', 0)
func syncronize(values: Array[Variant]):
	for i in range(len(self.properties)):
		self.get_node(self.root_path).set(self.properties[i], values[i])

#endregion
