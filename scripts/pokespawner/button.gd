extends Node3D

signal on_pressed(num)

@onready var anim = $AnimationPlayer
@onready var fingers = get_tree().get_nodes_in_group("index")

@export var number = 0

func _ready():
	$Area3D/button/number.text = str(number)

func _on_finger_entered(area):
	if area in fingers:
		on_pressed.emit(number)
		anim.play("press") # Replace with function body.
