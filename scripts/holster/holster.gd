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

const MIN_HOLSTER_ANGLE = 40
const HOLSTER_ANGLE_RANGE = 15

@onready var camera : XRCamera3D = %XRCamera3D
@onready var player_body : XRToolsPlayerBody = %PlayerBody

@onready var left : Node3D = $Left
@onready var right : Node3D = $Right
@onready var center_ref : Node3D = $CenterReference

### Lifecycle ###

# Moves holster based on angle from head to center of holster
func _process(_delta):
	# Position
	global_position = camera.global_position
	global_position.y = global_position.y * 0.6 + 0.05

	# Rotation
	global_rotation = camera.global_rotation * Vector3.UP

	# Holstering of left and right
	var intermediate_pos; var intermediate_rot
	
	var head_to_holster = center_ref.global_position - camera.global_position
	var angle_to_center = rad_to_deg((-camera.global_transform.basis.z).angle_to(head_to_holster))
	var interp = angle_to_center - MIN_HOLSTER_ANGLE
	interp = clamp(interp, 0, HOLSTER_ANGLE_RANGE)

	# left
	intermediate_pos = LEFT_HOME_POS.lerp(LEFT_STOW_POS, interp / HOLSTER_ANGLE_RANGE)
	left.position = intermediate_pos

	intermediate_rot = LEFT_HOME_ROT.lerp(LEFT_STOW_ROT, interp / HOLSTER_ANGLE_RANGE)
	left.rotation = intermediate_rot

	# right
	intermediate_pos = RIGHT_HOME_POS.lerp(RIGHT_STOW_POS, interp / HOLSTER_ANGLE_RANGE)
	right.position = intermediate_pos

	intermediate_rot = RIGHT_HOME_ROT.lerp(RIGHT_STOW_ROT, interp / HOLSTER_ANGLE_RANGE)
	right.rotation = intermediate_rot
