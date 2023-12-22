class_name WorldInCube
extends Node3D

@onready var cube : MeshInstance3D = $LeftPortalViewport/Cube
@onready var portal_ref : MeshInstance3D = $LeftPortalViewport/PortalReference
@onready var orphanage : Node3D = $LeftPortalViewport/Orphanage

var color
var world_accumulate = Vector3.ZERO
var previous_portal_pos

### Lifecycle ###

func _ready():
	var mat : Material = cube.get_surface_override_material(0)
	mat.albedo_color = color
	cube.set_surface_override_material(0, mat)



### Events ###

# Changes the position a small amount per tick
func _on_world_move(new_pos):
	portal_ref.global_position = world_accumulate + new_pos

	fix_pos()

#Saves the accumulated position when dropped
func _on_world_accumulate(accumulated_position):
	world_accumulate += accumulated_position

# Update the portal reference's position based on the movement of the portal
func _on_portal_move(current_portal_pos, orig_portal_pos):
	if not previous_portal_pos: previous_portal_pos = orig_portal_pos

	world_accumulate += current_portal_pos - previous_portal_pos
	portal_ref.global_position = world_accumulate

	previous_portal_pos = current_portal_pos

	fix_pos()

### Helper ###

# Bounds the portal within the larger cube
func fix_pos():
	var cube_pos = cube.global_position + cube.mesh.size / 2
	var cube_neg = cube.global_position - cube.mesh.size / 2

	var portal_pos = portal_ref.global_position + portal_ref.mesh.size / 2
	var portal_neg = portal_ref.global_position - portal_ref.mesh.size / 2

	if portal_pos.x > cube_pos.x: world_accumulate.x -= portal_pos.x - cube_pos.x
	if portal_pos.y > cube_pos.y: world_accumulate.y -= portal_pos.y - cube_pos.y
	if portal_pos.z > cube_pos.z: world_accumulate.z -= portal_pos.z - cube_pos.z

	if portal_neg.x < cube_neg.x: world_accumulate.x += cube_neg.x - portal_neg.x
	if portal_neg.y < cube_neg.y: world_accumulate.y += cube_neg.y - portal_neg.y
	if portal_neg.z < cube_neg.z: world_accumulate.z += cube_neg.z - portal_neg.z
