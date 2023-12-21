class_name Keypad
extends StaticBody3D

# keypad code adapted from https://www.youtube.com/watch?v=VKYjz5R73Os&ab_channel=DelanoLourenco
# and https://www.youtube.com/watch?v=mGYi7pnEgnA&ab_channel=Gwizz
@onready var globals = get_node("/root/Globals")
@onready var buttons = $Keypad/Buttons
@onready var id_label : Label3D = $Display/ID
@onready var anim : AnimationPlayer = $AnimationPlayer
signal spawn(num)

var id = ""



### Lifecycle ###

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons.get_children():
		if button is Node3D:
			button.on_pressed.connect(on_button_pressed)



### Events ###

func on_button_pressed(number):
	# takes in the entered id and changes the display
	id += str(number)
	id_label.text = str(id)
	
	if id.length() >= 3:
		# Spawn the correct pokemon based on the entered id
		var int_id = int(id)
		if int_id > 151 or int_id <= 0: spawn.emit(0)
		else: spawn.emit(int_id)
			
		id = ""
		anim.play("clear_display")

# clear the display one second after the pokemon is spawned
func clear_text():
	if id == "": id_label.text = ""
