class_name DigiPokeSnap
extends XRToolsSnapZone


### Overrided super methods ###

# Overwrite super._ready to allow for cube collision
func _ready():
	# Dont do this
	# $CollisionShape3D.shape.radius = grab_distance

	# Perform updates
	_update_snap_mode()

	# Perform the initial object check when next idle
	if not Engine.is_editor_hint():
		_initial_object_check.call_deferred()
	
# Adds rumble to hover over snap point with digital pokemon
func _on_snap_zone_body_entered(target: Node3D) -> void:
	# Ignore objects already known about
	if _object_in_grab_area.find(target) >= 0:
		return

	# Reject objects which don't support picking up
	if not target.has_method('pick_up'):
		return

	# Reject objects not in the required snap group
	if not snap_require.is_empty() and not target.is_in_group(snap_require):
		return

	# Reject objects in the excluded snap group
	if not snap_exclude.is_empty() and target.is_in_group(snap_exclude):
		return

	# Reject climbable objects
	if target is XRToolsClimbable:
		return

	# Add to the list of objects in grab area
	_object_in_grab_area.push_back(target)
	enter_rumble(target)

	# If this snap zone is configured to snap objects that are dropped, then
	# start listening for the objects dropped signal
	if snap_mode == SnapMode.DROPPED and target.has_signal("dropped"):
		target.connect("dropped", _on_target_dropped, CONNECT_DEFERRED)

	# Show highlight when something could be snapped
	if not is_instance_valid(picked_up_object):
		close_highlight_updated.emit(self, enabled)

# Adds rumble to exit hover over snap point with digital pokemon
func _on_snap_zone_body_exited(target: Node3D) -> void:
	# Rumble if leaves list
	if target in _object_in_grab_area:
		exit_rumble(target)

	# Ensure the object is not in our list
	_object_in_grab_area.erase(target)

	# Stop listening for dropped signals
	if target.has_signal("dropped") and target.is_connected("dropped", _on_target_dropped):
		target.disconnect("dropped", _on_target_dropped)

	# Hide highlight when nothing could be snapped
	if _object_in_grab_area.is_empty():
		close_highlight_updated.emit(self, false)



### Helper ###

# Rumble when hover over snap point with digital pokemon
func enter_rumble(target):
	if target.by_controller is RumbleController and not is_instance_valid(picked_up_object):
		target.by_controller.enter_rumble()

# Rumble when exit hover over snap point with digital pokemon
func exit_rumble(target):
	if target.by_controller is RumbleController and not is_instance_valid(picked_up_object):
		target.by_controller.exit_rumble()