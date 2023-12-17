class_name Box
extends Area3D

signal check_bounds(box, pos, neg) # Global position

signal take_priority(box)

@export var color : Color = Color("ad985b")

const MIN_SIZE = 0.1
const PADDING = 0.01 ## To prevent z-fighting

@onready var collision : CollisionShape3D = $Collision
@onready var boxes = $Boxes

@onready var portal : Portal = preload("res://scenes/computer/portal/portal.tscn").instantiate()
@onready var world_in_cube : WorldInCube = preload("res://scenes/computer/box/world_in_cube.tscn").instantiate()
@onready var portal_reference : Node3D = world_in_cube.get_node("LeftPortalViewport/PortalReference")

@onready var orig_position : Vector3 = global_position

var corners : Corners
var portal_ref_mesh : MeshInstance3D
var pokemon : Node3D

var save_pos : Vector3
var save_neg : Vector3



### Lifecycle ###

func _ready():
	corners = $Corners
	portal_ref_mesh = $PortalReferenceMesh
	pokemon = world_in_cube.get_node("LeftPortalViewport/Pokemon")

	for box in boxes.get_children():
		box.check_bounds.connect(_on_check_bounds)
		box.take_priority.connect(_on_take_priority)
	
	# Init world-in-cube and portal
	world_in_cube.color = color

	portal.camera_reference = world_in_cube

	get_tree().get_root().add_child.call_deferred(world_in_cube)
	add_child(portal)





### Events ###

func _on_corner_move(pos:Vector3, neg:Vector3):
	# Update size
	portal.mesh.size = pos - neg

	# Check and fix too small
	var fix = false
	if portal.mesh.size.x < MIN_SIZE:
		portal.mesh.size.x = MIN_SIZE
		pos.x = portal.global_position.x + MIN_SIZE / 2
		neg.x = portal.global_position.x - MIN_SIZE / 2
		fix = true
	else:
		portal.global_position.x = (pos.x + neg.x) / 2

	if portal.mesh.size.y < MIN_SIZE:
		portal.mesh.size.y = MIN_SIZE
		pos.y = portal.global_position.y + MIN_SIZE / 2
		neg.y = portal.global_position.y - MIN_SIZE / 2
		fix = true
	else:
		portal.global_position.y = (pos.y + neg.y) / 2

	if portal.mesh.size.z < MIN_SIZE:
		portal.mesh.size.z = MIN_SIZE
		pos.z = portal.global_position.z + MIN_SIZE / 2
		neg.z = portal.global_position.z - MIN_SIZE / 2
		fix = true
	else:
		portal.global_position.z = (pos.z + neg.z) / 2

	# Update collision to match
	collision.shape.size = portal.mesh.size
	collision.global_position = portal.global_position
	
	# Update portal reference mesh to match
	portal_ref_mesh.mesh.size = portal.mesh.size
	portal_ref_mesh.global_position = portal.global_position
	
	# Update portal reference to match
	portal_reference.mesh.size = portal.mesh.size
	portal_reference.global_position = portal.global_position - orig_position

	# Fix too small
	if fix: corners.fix_pos(pos, neg)

	# Save corners
	save_pos = pos
	save_neg = neg

	# Check and fix out of bounds
	check_bounds.emit(self, pos, neg)

	# Take priority
	take_priority.emit(self)

func fix_pos(pos, neg):
	corners.fix_pos(pos, neg)

	portal.mesh.size = pos - neg
	portal.global_position = (pos + neg) / 2

	# Update collision to match
	collision.shape.size = portal.mesh.size
	collision.global_position = portal.global_position
	
	# Update portal reference mesh to match
	portal_ref_mesh.mesh.size = portal.mesh.size
	portal_ref_mesh.global_position = portal.global_position
	
	# Update portal reference to match
	portal_reference.mesh.size = portal.mesh.size
	portal_reference.global_position = portal.global_position - orig_position

	# Save corners
	save_pos = pos
	save_neg = neg

func _on_request_fix_pos():
	corners.fix_pos(save_pos, save_neg)

func _on_check_bounds(child, child_pos, child_neg):
	# Check pos
	if child_pos.x > save_pos.x - PADDING: child_pos.x = save_pos.x - PADDING
	if child_pos.y > save_pos.y - PADDING: child_pos.y = save_pos.y - PADDING
	if child_pos.z > save_pos.z - PADDING: child_pos.z = save_pos.z - PADDING
	
	# Check neg
	if child_neg.x < save_neg.x + PADDING: child_neg.x = save_neg.x + PADDING
	if child_neg.y < save_neg.y + PADDING: child_neg.y = save_neg.y + PADDING
	if child_neg.z < save_neg.z + PADDING: child_neg.z = save_neg.z + PADDING

	child.fix_pos(child_pos, child_neg)

func _on_take_priority(child):
	boxes.move_child(child, 0)

	# Take priority for self
	take_priority.emit(self)



### Helper ###

func in_bounds(poke : DigitalPokemon):
	return overlaps_body(poke)

func adopt(poke : DigitalPokemon):
	if not in_bounds(poke): return false

	for box in boxes.get_children():
		var ret = box.adopt(poke)
		if ret: return true

	var portal_to_poke = poke.global_position - portal.global_position
	poke.reparent(pokemon)
	poke.global_position = portal_reference.global_position + portal_to_poke

	return true

func power(on : bool):
	for box in boxes.get_children():
		box.power(on)
	
	corners.power(on)
