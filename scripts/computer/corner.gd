class_name Corner
extends XRToolsPickable

signal corner_move(id, pos)
signal request_fix_pos

enum Id {X = 1, Y = 2, Z = 4}
@export_flags("x", "y", "z") var id = 0

@onready var starting_rotation = rotation
@onready var new_position = global_position


### Lifecycle ###

func _ready():
	super._ready()


func _process(_delta):
	rotation = starting_rotation # Lock rotation

	if is_picked_up():
		corner_move.emit(id, global_position)

func _integrate_forces(state):
	state.transform.origin = new_position



### Events ###

func _on_picked_up(pickable):
	request_highlight(pickable, true) # Keep highlight on pickup

func _on_dropped(pickable):
	request_highlight(pickable, false) # Drop highlight on pickup
	
	request_fix_pos.emit()

func _on_corner_move(_id, pos):
	if id != _id:
		if id & Id.X == _id & Id.X:
			global_position.x = pos.x
		if id & Id.Y == _id & Id.Y:
			global_position.y = pos.y
		if id & Id.Z == _id & Id.Z:
			global_position.z = pos.z



### Helpers ###

func fix_pos(pos, neg):
	new_position.x = pos.x if id & Id.X else neg.x
	new_position.y = pos.y if id & Id.Y else neg.y
	new_position.z = pos.z if id & Id.Z else neg.z
