class_name Portal
extends MeshInstance3D

@export var other_portal : Node3D
@export var fov = 93.0
@export var ipd = 0.068

@onready var main_cam : XRCamera3D = get_tree().get_root().get_node("Main/XROrigin3D/XRCamera3D")
@onready var helper : Node3D = $Helper
@onready var other_helper : Node3D = other_portal.get_node("Helper")

@onready var left_camera : Camera3D = $PortalViewport/Camera3D
@onready var right_camera : Camera3D = $PortalViewport2/Camera3D

@onready var material : Material = get_surface_override_material(0)

var xr_interface : XRInterface

### Lifecycle ###


func _process(_delta):
	helper.global_transform = main_cam.global_transform
	other_helper.transform = helper.transform

	left_camera.global_transform = other_helper.global_transform
	right_camera.global_transform = other_helper.global_transform
	# var dir = other_helper.global_transform.basis.x
	# left_camera.global_position -= dir * ipd / 2
	# right_camera.global_position += dir * ipd / 2
	# left_camera.fov = fov
	# right_camera.fov = fov

	# var diff = global_transform.origin - main_cam.global_transform.origin
	# var angle = main_cam.global_transform.basis.z.angle_to(diff)
	# var near_plane = helper.transform.origin.length()*abs(cos(angle))
	# left_camera.near = max(0.1, near_plane-4.2)
	# right_camera.near = max(0.1, near_plane-4.2)

	material.set_shader_parameter("viewport", left_camera.get_viewport().get_texture())
