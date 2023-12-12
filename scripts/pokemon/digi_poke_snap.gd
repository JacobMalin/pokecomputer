class_name DigiPokeSnap
extends XRToolsSnapZone

# Overwrite super._ready
func _ready():
	# Dont do this
	# $CollisionShape3D.shape.radius = grab_distance

	# Perform updates
	_update_snap_mode()

	# Perform the initial object check when next idle
	if not Engine.is_editor_hint():
		_initial_object_check.call_deferred()