class_name Holster
extends Node3D

const LEFT_HOME_POS  = Vector3(0, 0, -0.235)
const RIGHT_HOME_POS = Vector3(0, 0, -0.111)
const LEFT_HOME_ROT  = Vector3.ZERO
const RIGHT_HOME_ROT = Vector3.ZERO

const LEFT_STOW_POS  = Vector3(-0.235, 0, 0)
const RIGHT_STOW_POS = Vector3(0.235, 0, 0)
const LEFT_STOW_ROT  = Vector3(0, PI/2, 0)
const RIGHT_STOW_ROT = Vector3(0, -PI/2, 0)

const MIN_HOLSTER_INTERP = 0.15
const MAX_HOLSTER_INTERP = 0.25

@onready var camera : XRCamera3D = %XRCamera3D
@onready var player_body : XRToolsPlayerBody = %PlayerBody

@onready var left : Node3D = $Left
@onready var right : Node3D = $Right

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Position
	global_position = camera.global_position
	global_position.y = global_position.y * 0.6 + 0.05

	# Rotation
	global_rotation = camera.global_rotation * Vector3.UP

	# Holstering of left and right
	var intermediate_pos; var intermediate_rot
	var interp = %RightController.global_position.y - (global_position + LEFT_HOME_POS).y - MIN_HOLSTER_INTERP
	interp = clamp(interp, 0, MAX_HOLSTER_INTERP)

	# left
	intermediate_pos = LEFT_HOME_POS.lerp(LEFT_STOW_POS, interp / MAX_HOLSTER_INTERP)
	left.position = intermediate_pos

	intermediate_rot = LEFT_HOME_ROT.lerp(LEFT_STOW_ROT, interp / MAX_HOLSTER_INTERP)
	left.rotation = intermediate_rot

	# right
	intermediate_pos = RIGHT_HOME_POS.lerp(RIGHT_STOW_POS, interp / MAX_HOLSTER_INTERP)
	right.position = intermediate_pos

	intermediate_rot = RIGHT_HOME_ROT.lerp(RIGHT_STOW_ROT, interp / MAX_HOLSTER_INTERP)
	right.rotation = intermediate_rot
