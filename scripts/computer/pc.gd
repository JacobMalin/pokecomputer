class_name PC
extends Node3D

@export var on = true

@onready var desktop : Desktop = $Desktop
@onready var monitor_collision : CollisionShape3D = $MonitorArea/Collision

@onready var pokewatch = $"../XROrigin3D/LeftController/Pokewatch"

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var onAudio : AudioStreamPlayer3D = $OnSound
@onready var offAudio : AudioStreamPlayer3D = $OffSound

var disabled = false

### Lifecycle ###

func _ready():
	if !on: anim.play_backwards("on")
	
	pokewatch.panel_activate.connect(panel_press)


### Events ###

func _on_monitor_entered(area):
	if not disabled and area.is_in_group("index"):
		disabled = true
		
		if on:
			on = false
			anim.play("on")
			offAudio.play()
			desktop.power(false)
		else:
			on = true
			anim.play_backwards("on")
			onAudio.play()
		
		# Rumble
		area.rumble()

func panel_press(panel : String, location : Area3D):
	print(panel)

### Helper ###

# Add a digital pokemon to the computer
func adopt(poke : DigitalPokemon):
	desktop.adopt(poke)

func update_state(start : bool):
	if on:
		disabled = !start
		if start: desktop.power(true) # only show corners at end of opening animation
	else:
		disabled = start



