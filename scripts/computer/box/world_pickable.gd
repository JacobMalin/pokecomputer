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

func _process(_delta):
	rotation = starting_rotation # Lock rotation

	fix_pos()

	if by_controller: world_move.emit(portal_ref.global_position - global_position)

func _integrate_forces(state):
	rotation = starting_rotation # Helps prevent artifacts

	state.transform.origin = new_position



### Events ###

func _on_dropped(_pickable):
	world_accumulate.emit(portal_ref.global_position - global_position)



### Helpers ###

func fix_pos():	
	collision.shape.size = collision_ref.shape.size
	new_position = collision_ref.global_position

func disable():
	collision.set_deferred("disabled", true)

func enable():
	collision.set_deferred("disabled", false)
