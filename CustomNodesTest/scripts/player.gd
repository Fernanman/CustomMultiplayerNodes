class_name Player
extends CharacterBody2D

const SPEED = 150.0

@onready var inputs = $Inputs
@onready var sprite = $Sprite
@onready var collision = $Collision
# @onready var sync = $Sync

@export var serverside_pos: Vector2

func _ready():
	pass

func _physics_process(_delta):
	if self.inputs.is_multiplayer_authority():
		self.inputs.update()
		

	if self.is_multiplayer_authority():
		self.velocity = self.inputs.motion * SPEED
		self.move_and_slide()

		self.serverside_pos = self.position
	else:
		self.position = self.serverside_pos
	

func set_serverside_pos(pos: Vector2, global:bool=true):
	if global:
		self.serverside_pos = self.to_local(pos)
	else:
		self.serverside_pos = pos
