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

