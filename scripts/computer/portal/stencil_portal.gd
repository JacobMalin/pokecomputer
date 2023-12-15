class_name StencilPortal
extends MeshInstance3D

@export var other_portal : Node3D

@onready var xr_origin : XROrigin3D = get_tree().get_root().get_node("Main/XROrigin3D")
@onready var main_cam : XRCamera3D = xr_origin.get_node("XRCamera3D")
@onready var helper : Node3D = $Helper
@onready var other_helper : Node3D = other_portal.get_node("Helper")

@onready var left_portal_camera : Camera3D = $LeftPortalViewport/XROrigin3D/Camera3D
@onready var left_stencil_camera : Camera3D = $LeftStencilViewport/XROrigin3D/Camera3D
@onready var right_portal_camera : Camera3D = $RightPortalViewport/XROrigin3D/Camera3D
@onready var right_stencil_camera : Camera3D = $RightStencilViewport/XROrigin3D/Camera3D

@onready var material : Material = get_surface_override_material(0)

var xr_interface : XRInterface

### Lifecycle ###

func _ready():
	xr_interface = XRServer.find_interface('OpenXR')
	print(xr_interface.get_render_target_size())

func _process(_delta):
	helper.global_transform = main_cam.global_transform
	other_helper.transform = helper.transform

	left_portal_camera.global_transform = helper.global_transform
	left_stencil_camera.global_transform = helper.global_transform
	right_portal_camera.global_transform = helper.global_transform
	right_stencil_camera.global_transform = helper.global_transform
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

	# material.set_shader_parameter("viewport", left_camera.get_viewport().get_texture())

	
	
	var left_transform = xr_interface.get_transform_for_view(0, xr_origin.global_transform)
	var right_transform = xr_interface.get_transform_for_view(1, xr_origin.global_transform)
	var ipd = left_transform.origin.distance_to(right_transform.origin)

	left_portal_camera.h_offset = -ipd / 2
	left_stencil_camera.h_offset = -ipd / 2
	right_portal_camera.h_offset = ipd / 2
	right_stencil_camera.h_offset = ipd / 2
