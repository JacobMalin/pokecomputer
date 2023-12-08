class_name Box
extends Node3D

signal check_bounds(box, pos, neg) # Global position

@export var color : Color = Color("ad985b")

const MIN_SIZE = 0.1
const PADDING = 0.01 ## To prevent z-fighting

@onready var cube : MeshInstance3D = $Cube
@onready var boxes = $Boxes
var corners

var save_pos : Vector3
var save_neg : Vector3



### Lifecycle ###

func _ready():
	corners = $Corners

	var mat : Material = cube.get_surface_override_material(0)
	mat.albedo_color = color
	cube.set_surface_override_material(0, mat)

	save_pos = corners.get_pos_corner()
	save_neg = corners.get_neg_corner()

	for box in boxes.get_children():
		box.check_bounds.connect(_on_check_bounds)


### Events ###

func _on_corner_move(pos:Vector3, neg:Vector3):
	# Update size
	cube.mesh.size = pos - neg

	# Check and fix too small
	var fix = false
	if cube.mesh.size.x < MIN_SIZE:
		cube.mesh.size.x = MIN_SIZE
		pos.x = cube.global_position.x + MIN_SIZE / 2
		neg.x = cube.global_position.x - MIN_SIZE / 2
		fix = true
	else:
		cube.global_position.x = (pos.x + neg.x) / 2

	if cube.mesh.size.y < MIN_SIZE:
		cube.mesh.size.y = MIN_SIZE
		pos.y = cube.global_position.y + MIN_SIZE / 2
		neg.y = cube.global_position.y - MIN_SIZE / 2
		fix = true
	else:
		cube.global_position.y = (pos.y + neg.y) / 2

	if cube.mesh.size.z < MIN_SIZE:
		cube.mesh.size.z = MIN_SIZE
		pos.z = cube.global_position.z + MIN_SIZE / 2
		neg.z = cube.global_position.z - MIN_SIZE / 2
		fix = true
	else:
		cube.global_position.z = (pos.z + neg.z) / 2

	# Fix too small
	if fix: corners.fix_pos(pos, neg)

	# Save corners
	save_pos = pos
	save_neg = neg

	# Check and fix out of bounds
	check_bounds.emit(self, pos, neg)

func fix_pos(pos, neg):
	corners.fix_pos(pos, neg)

	cube.mesh.size = pos - neg
	cube.global_position = (pos + neg) / 2

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
