class_name MinimizedBox
extends XRToolsPickable

@onready var parent_box : Box = get_parent()
@onready var mesh : MeshInstance3D = $Mesh
@onready var collision : CollisionShape3D = $Collision
@onready var area_collision : CollisionShape3D = $DoubleTapArea/Collision

@onready var starting_rotation = rotation
@onready var new_postion = global_position

### Lifecycle ###

func _ready():
	var mat : Material = mesh.get_surface_override_material(0)
	mat.albedo_color = parent_box.color
	mesh.set_surface_override_material(0, mat)

# Locks the rotation of the minimized box so it can't be rotated
func _process(_delta):
	rotation = starting_rotation

# Updates global position of the minimized box
func _integrate_forces(__state):
	rotation = starting_rotation # Helps prevent artifacts

	global_position = new_postion

### Helpers ###

# Shows minimized box and enables collisions
func enable():
	show()
	collision.set_deferred("disabled", false)
	area_collision.set_deferred("disabled", false)

# Hides minimized box and disables collisions
func disable():
	hide()
	collision.set_deferred("disabled", true)
	area_collision.set_deferred("disabled", true)

# Fixes the minimized box so it stays inside the bounds of the parent box
func fix_pos(pos, neg, padding):
	var _new_position = global_position

	global_position = _new_position.clamp(neg + Vector3.ONE * padding + mesh.mesh.size / 2, pos - Vector3.ONE * padding - mesh.mesh.size / 2)
	new_postion = global_position

# Updates the position of the minimized box
func set_minimized_position(new_pos):
	global_position = new_pos
	new_postion = new_pos
