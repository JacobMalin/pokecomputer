class_name PC
extends Node3D

@export var on = true

@onready var desktop : Desktop = $Desktop
@onready var monitor_collision : CollisionShape3D = $MonitorArea/Collision

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var onAudio : AudioStreamPlayer3D = $OnSound
@onready var offAudio : AudioStreamPlayer3D = $OffSound

var disabled = false

### Lifecycle ###

func _ready():
	if !on:
		anim.play.call_deferred("on")
		desktop.power.call_deferred(false)


### Events ###

# Turns monitor on/off when pressed and gives haptic feedback
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

# Receives signal from watch and relays to desktop
func _on_panel_press(panel : String, location : Area3D, _position : Vector3):
	desktop._on_panel_press(panel, location, _position)

### Helper ###

# Add a digital pokemon to the computer
func adopt(poke : DigitalPokemon):
	desktop.adopt(poke)

# Called during the animation for on. Updates disabled and desktop power
func update_state(start : bool):
	if on:
		disabled = !start
		if start: desktop.power(true)
	else:
		disabled = start
