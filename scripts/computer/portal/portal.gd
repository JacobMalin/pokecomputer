class_name Portal
extends MeshInstance3D

@export var camera_reference : Node3D

@onready var main : XRToolsStartXR = get_tree().get_root().get_node("Main")
@onready var xr_origin : XROrigin3D = main.get_node("XROrigin3D")
@onready var main_cam : XRCamera3D = xr_origin.get_node("XRCamera3D")
@onready var helper : Node3D = $Helper

@onready var portal_reference : Node3D = camera_reference.get_node("LeftPortalViewport/PortalReference")
@onready var reference_helper : Node3D = portal_reference.get_node("Helper")
@onready var left_portal_camera : Camera3D = camera_reference.get_node("LeftPortalViewport/LeftCamera")
@onready var right_portal_camera : Camera3D = camera_reference.get_node("LeftPortalViewport/RightPortalViewport/RightCamera")

@onready var material : Material = get_surface_override_material(0)

var xr_interface : XRInterface

### Lifecycle ###

func _ready():
	xr_interface = XRServer.find_interface('OpenXR')

	## Set shader params
	var left_viewport = camera_reference.get_node("LeftPortalViewport")
	var right_viewport = camera_reference.get_node("LeftPortalViewport/RightPortalViewport")

	material.set_shader_parameter("left_tex", left_viewport.get_texture())
	material.set_shader_parameter("right_tex", right_viewport.get_texture())

# Sets the position of the portal cameras, changes the distance of the two portal cameras to match the IPD
func _process(_delta):
	## Move cameras
	helper.global_transform = main_cam.global_transform
	reference_helper.transform = helper.transform

	left_portal_camera.global_transform = reference_helper.global_transform
	right_portal_camera.global_transform = reference_helper.global_transform

	
	if main.xr_active:
		## Calculate IPD
		var left_transform = xr_interface.get_transform_for_view(0, xr_origin.global_transform)
		var right_transform = xr_interface.get_transform_for_view(1, xr_origin.global_transform)
		var ipd = left_transform.origin.distance_to(right_transform.origin)

		## Apply IPD to camera offset
		left_portal_camera.h_offset = -ipd / 2
		right_portal_camera.h_offset = ipd / 2
