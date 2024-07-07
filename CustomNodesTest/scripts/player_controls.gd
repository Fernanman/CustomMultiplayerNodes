class_name PlayerControls
extends Node2D

@export var motion: Vector2 

func _ready():
	pass


func update():
	self.motion = Vector2.ZERO

	self.motion.x = Input.get_axis("ui_left", "ui_right")
	self.motion.y = Input.get_axis("ui_up", "ui_down")
	# Normalizes it so the speed is constant when moving diagonally
	self.motion = self.motion.normalized()