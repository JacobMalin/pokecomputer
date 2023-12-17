extends Node3D

@onready var portal_ref = get_node("../PortalReference")
@onready var camera = get_node("../LeftCamera")
var pos
var neg

# Called when the node enters the scene tree for the first time.
func _ready():
	var clip_mat = preload("res://assets/clip_material.tres")
	for child in get_children():
		child.set_surface_override_material(0, clip_mat.duplicate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pos = portal_ref.global_position + portal_ref.mesh.size / 2
	neg = portal_ref.global_position - portal_ref.mesh.size / 2

	for child in get_children():
		var mat = child.get_surface_override_material(0)
		mat.set_shader_parameter("pos", pos)
		mat.set_shader_parameter("neg", neg)
		mat.set_shader_parameter("w_cam", camera.global_position)
