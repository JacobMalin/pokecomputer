class_name WorldInCube
extends Node3D

var color

@onready var cube : MeshInstance3D = $LeftPortalViewport/Cube

func _ready():
	var mat : Material = cube.get_surface_override_material(0)
	mat.albedo_color = color
	cube.set_surface_override_material(0, mat)
