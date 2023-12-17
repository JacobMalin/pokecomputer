class_name Pokewatch
extends Node3D

@onready var camera : XRCamera3D = %XRCamera3D

@onready var controller = get_parent()

@onready var red = $Red
@onready var white = $White
@onready var button = $Button

enum PokewatchMode {
	DEFAULT,
	DESKTOP,
	BOX
}
var pokewatch_mode : PokewatchMode = PokewatchMode.DEFAULT

var location : Area3D

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
		if panel is Area3D:
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
	


### Events ###

func _on_button_pressed(_name):
	if _name == TRIGGER_ACTION: trigger = true
	elif _name == GRIP_ACTION: grip = true

func _on_button_released(_name):
	if _name == TRIGGER_ACTION: trigger = false
	elif _name == GRIP_ACTION: grip = false
	
func _on_panel_pressed(function):
	print(function)

### Signals ###

func _on_area_entered(area:Area3D):
	location = area
	if area.is_in_group("desktop"):
		pokewatch(PokewatchMode.DESKTOP)
	elif area.is_in_group("box"):
		pokewatch(PokewatchMode.BOX)
		
func _on_area_exited(area:Area3D):
	if area.is_in_group("desktop"):
		pokewatch(PokewatchMode.DEFAULT)



### Helper ###

func pokewatch(_pokewatch_mode):
	pokewatch_mode = _pokewatch_mode

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
