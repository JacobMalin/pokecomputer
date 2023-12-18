extends Area3D
class_name PokewatchPanel

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var controller : XRController3D = get_parent().get_parent()

@export var function = ""

signal on_pressed(function)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_finger_entered(area):
	if area.get_parent() != controller and area.is_in_group("index"):
		anim.play("press")
		on_pressed.emit(function)

		# Rumble
		area.rumble()

func make_invisible():
	hide()
	collision.set_deferred("disabled", true)

func make_visible(): 
	show()
	collision.set_deferred("disabled", false)
