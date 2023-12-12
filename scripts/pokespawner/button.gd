extends Node3D

@export var number = 0
@export var disabled = false

signal on_pressed(num)

@onready var audio : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var number_label : Label3D = $Mesh/Number

func _ready():
	number_label.text = str(number)

func _on_finger_entered(area):
	if not disabled and area.is_in_group("index"):
		disabled = true
		
		anim.play("press")
		audio.play()

		on_pressed.emit(number)

		# Rumble
		area.rumble()
