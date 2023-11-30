extends Node3D

signal on_pressed

@onready var anim = $AnimationPlayer
@onready var fingers = get_tree().get_nodes_in_group("index")

@export var number = 0

func _ready():
	pass # Replace with function body.

func _on_finger_entered(area):
	if area in fingers:
		emit_signal("on_pressed", number)
		anim.play("press") # Replace with function body.
