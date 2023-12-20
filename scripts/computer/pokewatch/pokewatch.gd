class_name Pokewatch
extends Node3D

@onready var camera : XRCamera3D = %XRCamera3D

@onready var controller = get_parent()

@onready var red = $Red
@onready var white = $White
@onready var button = $Button

signal panel_activate(panel, area)

enum PokewatchMode {
	DEFAULT,
	DESKTOP,
	BOX
}
var pokewatch_mode : PokewatchMode = PokewatchMode.DEFAULT

var location : Area3D
var desktop_location : Area3D
var box_location : Area3D

var box_ct = 0

const TRIGGER_ACTION = "trigger_click"
const GRIP_ACTION = "grip_click"
const VIEW_ANGLE = 50

var trigger = false
var grip = false

### Lifecycle ###

# Called when the node enters the scene tree for the first time.
func _ready():
	controller.button_pressed.connect(_on_button_pressed)
	controller.button_released.connect(_on_button_released)
	
	for panel in get_children():
		if panel is PokewatchPanel:
			panel.on_pressed.connect(_on_panel_pressed)

	pokewatch(pokewatch_mode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	## Check angle of axis-x-of-watch to watch-to-head
	var watch_x = global_transform.basis.y
	var watch_to_head = camera.global_position - global_position

	var angle = rad_to_deg(watch_x.angle_to(watch_to_head))


	## Update visiblity
	visible = not trigger and not grip and angle < VIEW_ANGLE
	
	pokewatch(pokewatch_mode)


### Events ###

func _on_button_pressed(_name):
	if _name == TRIGGER_ACTION: trigger = true
	elif _name == GRIP_ACTION: grip = true

func _on_button_released(_name):
	if _name == TRIGGER_ACTION: trigger = false
	elif _name == GRIP_ACTION: grip = false
	
func _on_panel_pressed(function):
	panel_activate.emit(function, location)

### Signals ###

func _on_area_entered(area:Area3D):
	# check if the user is in the desktop, change modes accordingly
	if area.is_in_group("desktop"):
		desktop_location = area
		location = desktop_location
		pokewatch(PokewatchMode.DESKTOP)
		
	# check if the user is in a box, change modes accordingly
	elif area.is_in_group("box"):
		box_location = area
		location = box_location
		pokewatch(PokewatchMode.BOX)
		box_ct += 1
		
func _on_area_exited(area:Area3D):
	if area.is_in_group("desktop"):
		pokewatch(PokewatchMode.DEFAULT)
	
	# if the user leaves one of the main boxes, switch to desktop mode
	elif area.is_in_group("box") and box_ct == 1:
		box_ct = 0
		location = desktop_location
		pokewatch(PokewatchMode.DESKTOP)
		
	# if the user leaves one box and goes to another, switch location to parent box
	elif area.is_in_group("box") and box_ct > 1: 
		#box_location = area.get_parent().get_parent()
		location = box_location
		box_ct -= 1


### Helper ###

# Define the different modes of the Pokewatch
func pokewatch(_pokewatch_mode):
	pokewatch_mode = _pokewatch_mode

	if !visible:
		red.make_invisible()
		white.make_invisible()
		button.make_invisible()

	match pokewatch_mode:
		PokewatchMode.DEFAULT:
			red.make_invisible()
			white.make_invisible()
			button.make_invisible()
		PokewatchMode.DESKTOP:
			red.make_visible()
			white.make_invisible()
			button.make_invisible()
		PokewatchMode.BOX:
			red.make_visible()
			white.make_visible()
			button.make_visible()
