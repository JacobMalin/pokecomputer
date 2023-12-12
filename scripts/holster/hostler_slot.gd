extends XRToolsSnapZone

@onready var all_computer = get_tree().get_nodes_in_group("computer")

var holster_mode : HolsterMode = HolsterMode.DEFAULT
enum HolsterMode {
	DEFAULT,
	DIGITAL
}



### Lifecycle ###

# Overwrite super._ready
func _ready():
	# Dont do this
	# $CollisionShape3D.shape.radius = grab_distance

	# Perform updates
	_update_snap_mode()

	# Perform the initial object check when next idle
	if not Engine.is_editor_hint():
		_initial_object_check.call_deferred()


func _process(delta):
	super._process(delta)



### Super Overrides ###

# Pickup Method: Drop the currently picked up object
func drop_object() -> void:
	if not is_instance_valid(picked_up_object):
		return

	picked_up_object.exit_holster()

	# let go of this object
	picked_up_object.let_go(Vector3.ZERO, Vector3.ZERO)
	picked_up_object = null
	has_dropped.emit()
	highlight_updated.emit(self, enabled)
	
# Called when a body enters the snap zone
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

# Called when a body leaves the snap zone
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



### Signals ###

func _on_area_entered(area:Area3D):
	if area in all_computer:
		holster(HolsterMode.DIGITAL)


func _on_area_exited(area:Area3D):
	if area in all_computer:
		holster(HolsterMode.DEFAULT)


func _on_has_picked_up(what):
	what.enter_holster()



### Helper ###

func holster(_holster_mode):
	holster_mode = _holster_mode

	match holster_mode:
		HolsterMode.DEFAULT:
			if picked_up_object: picked_up_object.exit_computer()
			visible = true
			enabled = true
		HolsterMode.DIGITAL:
			if picked_up_object: picked_up_object.enter_computer()
			else: visible = false
			enabled = false

func enter_rumble(target):
	if target.by_controller is RumbleController and not is_instance_valid(picked_up_object):
		target.by_controller.enter_rumble()

func exit_rumble(target):
	if target.by_controller is RumbleController and not is_instance_valid(picked_up_object):
		target.by_controller.exit_rumble()

