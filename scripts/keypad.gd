extends StaticBody3D

# keypad code adapted from https://www.youtube.com/watch?v=VKYjz5R73Os&ab_channel=DelanoLourenco
# and https://www.youtube.com/watch?v=mGYi7pnEgnA&ab_channel=Gwizz
@onready var buttons = $Keypad/Buttons

var id = ""

signal on_keypad_press

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in buttons.get_children():
		if child is MeshInstance3D:
			child.on_pressed.connect(on_button_pressed)

func on_button_pressed(number):
	print("number: " + number)
