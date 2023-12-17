extends Area3D

@onready var anim : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_finger_entered(area):
	if area.is_in_group("index"):
		anim.play("press")
		print("red")

		# Rumble
		area.rumble()
