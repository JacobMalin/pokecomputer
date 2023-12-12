class_name PC
extends Node3D

@export var on = true

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var onAudio : AudioStreamPlayer3D = $OnSound
@onready var offAudio : AudioStreamPlayer3D = $OffSound
@onready var monitor_collision : CollisionShape3D = $MonitorArea/Collision

var disabled = false

### Lifecycle ###

func _ready():
	if !on: anim.play_backwards("on")



### Events ###

func _on_monitor_entered(area):
	if not disabled and area.is_in_group("index"):
		disabled = true
		
		if on:
			on = false
			anim.play("on")
			offAudio.play()
		else:
			on = true
			anim.play_backwards("on")
			onAudio.play()
		
		# Rumble
		area.rumble()



### Helper ###

# Add a digital pokemon to the computer
func adopt(poke : DigitalPokemon):
	poke.reparent(self)

func update_disabled(start : bool):
	if on: disabled = !start
	else: disabled = start


