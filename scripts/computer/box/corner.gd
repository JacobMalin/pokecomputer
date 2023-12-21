class_name Corner
extends XRToolsPickable

signal corner_move(id, pos)
signal request_fix_pos(corner)

enum Id {X = 1, Y = 2, Z = 4}
@export_flags("x", "y", "z") var id = 0

@onready var collision : CollisionShape3D = $Collision

@onready var starting_rotation = rotation
@onready var new_position = global_position


### Lifecycle ###

func _ready():
	super._ready()


func _process(_delta):
	rotation = starting_rotation # Lock rotation

	if is_picked_up():
		corner_move.emit(id, global_position)
		new_position = global_position

func _integrate_forces(state):
	rotation = starting_rotation # Helps prevent artifacts

	state.transform.origin = new_position



### Super Overrides ###

## This method requests highlighting of the [XRToolsPickable].
## If [param from] is null then all highlighting requests are cleared,
## otherwise the highlight request is associated with the specified node.
func request_highlight(from : Node, on : bool = true) -> void:
	# Save if we are highlighted
	var old_highlighted := _highlighted

	# Update the highlight requests dictionary
	if not from:
		_highlight_requests.clear()
	elif on:
		_highlight_requests[from] = from
	else:
		if not by_controller: ## Keep highlight when held
			_highlight_requests.erase(from)

	# Update the highlighted state
	_highlighted = _highlight_requests.size() > 0

	# Report any changes
	if _highlighted != old_highlighted:
		emit_signal("highlight_updated", self, _highlighted)



### Events ###

func _on_corner_move(_id, pos):
	if id != _id:
		if id & Id.X == _id & Id.X:
			new_position.x = pos.x
		if id & Id.Y == _id & Id.Y:
			new_position.y = pos.y
		if id & Id.Z == _id & Id.Z:
			new_position.z = pos.z



### Helpers ###

func fix_pos(pos, neg):
	global_position.x = pos.x if id & Id.X else neg.x
	global_position.y = pos.y if id & Id.Y else neg.y
	global_position.z = pos.z if id & Id.Z else neg.z
	new_position = global_position

func fix_bounds(pos, neg, padding):
	var _new_position = global_position

	global_position = _new_position.clamp(neg + Vector3.ONE * padding, pos - Vector3.ONE * padding)
	new_position = global_position
	

func power(on : bool):
	enabled = on
	collision.set_deferred("disabled", !on)

func disable():
	collision.set_deferred("disabled", true)

func enable():
	collision.set_deferred("disabled", false)
