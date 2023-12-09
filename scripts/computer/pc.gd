class_name PC
extends Node3D

@onready var fingers = get_tree().get_nodes_in_group("index")
@onready var anim = $AnimationPlayer
@onready var onAudio = $OnSound
@onready var offAudio = $OffSound
### Helper ###

var on = true

# Add a digital pokemon to the computer
func adopt(poke : DigitalPokemon):
	poke.reparent(self)


func _on_monitor_entered(area):
	print("test1")
	if area in fingers:
		if !on:
			anim.play_backwards("on")
			on = true
			onAudio.play()
			print("test")
		else:
			anim.play("on")
			on = false
			offAudio.play()
			print("test")
