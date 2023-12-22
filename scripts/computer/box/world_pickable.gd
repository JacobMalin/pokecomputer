class_name WorldPickable
extends XRToolsPickable

signal world_move(new_position)
signal world_accumulate(accumulated_position)


@onready var collision_ref : CollisionShape3D = get_parent().get_node("Collision")
@onready var portal_ref : MeshInstance3D = get_parent().get_node("PortalReferenceMesh")

@onready var collision : CollisionShape3D = $Collision

@onready var starting_rotation = rotation
@onready var new_position = global_position
@onready var accumulated_position = Vector3.ZERO


### Lifecycle ###

# Locks the rotation, bounds it to the parent box, and signals the parent box of the 
# position when held by a controller
func _process(_delta):
	rotation = starting_rotation # Lock rotation

	fix_pos()

	if by_controller: world_move.emit(portal_ref.global_position - global_position)

# Updates global position of the minimized box
func _integrate_forces(state):
	rotation = starting_rotation # Helps prevent artifacts

	state.transform.origin = new_position



### Events ###

# Signals the parent box of the accumulated position when dropped by a controller
func _on_dropped(_pickable):
	world_accumulate.emit(portal_ref.global_position - global_position)



### Helpers ###

# Updates the position and size of collision to match collision of the box
func fix_pos():	
	collision.shape.size = collision_ref.shape.size
	new_position = collision_ref.global_position

# Disables collision
func disable():
	collision.set_deferred("disabled", true)

# Enables collision
func enable():
	collision.set_deferred("disabled", false)
