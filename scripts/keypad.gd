extends StaticBody3D

# keypad code adapted from https://www.youtube.com/watch?v=VKYjz5R73Os&ab_channel=DelanoLourenco
# and https://www.youtube.com/watch?v=mGYi7pnEgnA&ab_channel=Gwizz
@onready var globals = get_node("/root/Globals")
@onready var buttons = $Keypad/Buttons

signal spawn(num)

var id = ""

# signal on_keypad_press

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in $Keypad/Buttons.get_children():
		if child is Node3D:
			child.on_pressed.connect(on_button_pressed)

func on_button_pressed(number):
	# takes in the entered id
	if id.length() < 2:
		id += str(number)
	else:
		id += str(number)
		# spawn the correct pokemon based on the entered id
		if int(id) > 151:
			spawn.emit(0)
			print("substitute")
		else:
			spawn.emit(int(id))
			print(Globals.pokedex[int(id)])
		id = ""
