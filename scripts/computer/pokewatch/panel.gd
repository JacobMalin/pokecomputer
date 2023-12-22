extends Area3D
class_name PokewatchPanel

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var controller : XRController3D = get_parent().get_parent()

@export var function = ""
@export var disabled = false

signal on_pressed(function)

### Events ###

# Signals the specific function of the panel pressed when a panel is pressed
func _on_finger_entered(area):
	if area.get_parent() != controller and area.is_in_group("index") and not disabled:
		disabled = true
		
		anim.play("press")
		on_pressed.emit(function)

		# Rumble
		area.rumble()


### Helpers ###

# Makes the panel invisible
func make_invisible():
	hide()
	collision.set_deferred("disabled", true)

# Makes the panel visible
func make_visible(): 
	show()
	collision.set_deferred("disabled", false)
