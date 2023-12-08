class_name PortalCamera
extends Node3D

# enum Eye {LEFT, RIGHT}
# @export var eye : Eye = Eye.LEFT

@export var offset = 0.1

@onready var parent_portal : Portal = get_parent()
@onready var main_cam : XRCamera3D = get_tree().get_root().get_node("Main/XROrigin3D/XRCamera3D")

@onready var left_cam : Camera3D = $PortalViewport/Camera3D
@onready var right_cam : Camera3D = $PortalViewport2/Camera3D

@onready var helper : Node3D = $Helper


### Lifecycle ###

func _process(_delta):
	var portal_to_cam = main_cam.global_position - parent_portal.global_position
	global_position = parent_portal.other_portal.global_position + portal_to_cam

	global_rotation = main_cam.global_rotation

	# helper.global_transform = main_cam.global_transform
	# other_portal.helper.transform = helper.transform
	# g.portal_camera.global_transform = other_portal.helper.global_transform
	# var diff = global_transform.origin - main_cam.global_transform.origin
	# var angle = main_cam.global_transform.basis.z.angle_to(diff)
	# var near_plane = helper.transform.origin.length()*abs(cos(angle))
	# g.portal_camera.near = max(0.1, near_plane-4.2)
