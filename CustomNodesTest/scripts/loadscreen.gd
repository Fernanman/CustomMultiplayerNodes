class_name TestClientServerLoad
extends Node2D


@export var port: int
@export var server_addr: String
@export var capacity: int

@onready var host_menu = $HostMenu
@onready var join_menu = $JoinMenu

var multiplayer_node



func _on_host_pressed():
	self.host_menu.visible = false
	self.join_menu.visible = false

	self.multiplayer_node = Server.new(self.port, self.capacity, ENetConnection.COMPRESS_RANGE_CODER)
	self.get_parent().add_child(self.multiplayer_node)
	self.get_parent().move_child(self.multiplayer_node, 0)

	self.queue_free()


func _on_join_pressed():
	self.host_menu.visible = false
	self.join_menu.visible = false

	self.multiplayer_node = Client.new(self.port, self.server_addr, ENetConnection.COMPRESS_RANGE_CODER)
	self.multiplayer_node.set_name("NetworkConnection")
	self.get_parent().add_child(self.multiplayer_node)
	self.get_parent().move_child(self.multiplayer_node, 0)

	self.queue_free()
