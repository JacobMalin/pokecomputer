class_name DigitalPokemon
extends XRToolsPickable

const POKEBALL_SCALE = 0.03

@export var id: int = 0
var pokemon_name: String

enum CaptureState {
	HOLSTER,
	DIGITAL
}
@export var capture_state : CaptureState = CaptureState.HOLSTER

enum SizeState {
	SMALL,
	LARGE
}
@export var size_state : SizeState = SizeState.SMALL

enum TangibleState {
	TANGIBLE,
	INTANGIBLE
}
@export var tangible_state : TangibleState = TangibleState.TANGIBLE

@onready var globals = get_node("/root/Globals")
@onready var collision: CollisionShape3D = $Collision
@onready var cry_player: AudioStreamPlayer3D = $CryPlayer
@onready var digi_anim_player: AnimationPlayer = $AnimationPlayer
@onready var tangible_area: Area3D = $TangibleArea

@onready var pc: PC = get_tree().get_root().get_node("Main").get_node("%PC")
@onready var desktop: Desktop = pc.get_node("Desktop")
@onready var clip_mat = preload("res://assets/computer/box/inverse_clip_material.tres")

@onready var new_position = global_position

var mesh
var copy : DigitalPokemonCopy
var poke_anim_player: AnimationPlayer

var in_box : Box
var shader_update_list = []

## Lifecycle ##

func _ready():
	super._ready()

	pokemon_name = globals.pokedex[id]

	## Attach model based on id
	var pokemon_scene = load("res://assets/pokemon/scenes/"+pokemon_name+".tscn")
	mesh = pokemon_scene.instantiate()

	mesh.name = "Mesh"
	mesh.scale = Vector3.ONE * POKEBALL_SCALE

	apply_shader(mesh)
	add_child(mesh)

	## Load cry based on id
	var pokemon_cry = load("res://assets/pokemon/cries/"+pokemon_name+".mp3")
	cry_player.stream = pokemon_cry

	poke_anim_player = mesh.get_node("AnimationPlayer")

	idle()

func _process(_delta):
	if in_box and in_box != desktop:
		var pos = in_box.portal.global_position + in_box.portal.mesh.size / 2
		var neg = in_box.portal.global_position - in_box.portal.mesh.size / 2

		for mat in shader_update_list:
			mat.set_shader_parameter("override", false)
			mat.set_shader_parameter("pos", pos)
			mat.set_shader_parameter("neg", neg)
			mat.set_shader_parameter("w_cam", in_box.camera.global_position)
	else:
		for mat in shader_update_list:
			mat.set_shader_parameter("override", true)

# func _integrate_forces(state):
# 	state.transform.origin = new_position



### Super Overrides ###

# Called when this object is dropped
func let_go(p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	# Skip if idle
	if _state == PickableState.IDLE:
		return

	# If held then detach from holder
	if _state == PickableState.HELD:
		match hold_method:
			HoldMethod.REPARENT:
				var original_transform = global_transform
				picked_up_by.remove_child(self)
				original_parent.add_child(self)
				global_transform = original_transform

			HoldMethod.REMOTE_TRANSFORM:
				_remote_transform.remote_path = NodePath()
				_remote_transform.queue_free()
				_remote_transform = null

	# Restore RigidBody mode
	freeze = restore_freeze
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer

	# Set velocity
	linear_velocity = p_linear_velocity
	angular_velocity = p_angular_velocity

	# If we are held by a hand then remove any hand-pose-override we may have
	# given it.
	if by_hand:
		by_hand.remove_pose_override(self)
		_on_let_go_by_controller() ## This line is new

	# If we are held by a cillision hand then remove any collision exceptions
	# we may have added.
	if by_collision_hand:
		remove_collision_exception_with(by_collision_hand)
		by_collision_hand.remove_collision_exception_with(self)

	# we are no longer picked up
	_state = PickableState.IDLE
	picked_up_by = null
	by_controller = null
	by_hand = null
	by_collision_hand = null
	hold_node = null

	# Stop any XRToolsMoveTo being used for remote grabbing
	if _move_to:
		_move_to.stop()
		_move_to.queue_free()
		_move_to = null

	# let interested parties know
	dropped.emit(self)

# Called when this object is picked up
func pick_up(by: Node3D, with_controller: XRController3D) -> void:
	# Skip if disabled or already picked up
	if not enabled or _state != PickableState.IDLE:
		return

	if picked_up_by:
		let_go(Vector3.ZERO, Vector3.ZERO)

	# remember who picked us up
	picked_up_by = by
	by_controller = with_controller
	hold_node = with_controller if with_controller else by
	by_hand = XRToolsHand.find_instance(by_controller)
	by_collision_hand = XRToolsCollisionHand.find_instance(by_controller)
	_active_grab_point = _get_grab_point(by)

	# If we have been picked up by a hand then apply the hand-pose-override
	# from the grab-point.
	if by_hand and _active_grab_point:
		var grab_point_hand := _active_grab_point as XRToolsGrabPointHand
		if grab_point_hand and grab_point_hand.hand_pose:
			by_hand.add_pose_override(self, GRIP_POSE_PRIORITY, grab_point_hand.hand_pose)

	if by_hand:
		_on_picked_up_by_controller() ## This line is new

	# If we have been picked up by a collision hand then add collision
	# exceptions to prevent the hand and pickable colliding.
	if by_collision_hand:
		add_collision_exception_with(by_collision_hand)
		by_collision_hand.add_collision_exception_with(self)

	# Remember the mode before pickup
	match release_mode:
		ReleaseMode.UNFROZEN:
			restore_freeze = false

		ReleaseMode.FROZEN:
			restore_freeze = true

		_:
			restore_freeze = freeze

	# turn off physics on our pickable object
	freeze = true
	collision_layer = picked_up_layer
	collision_mask = 0

	if by.picked_up_ranged:
		if ranged_grab_method == RangedMethod.LERP:
			_start_ranged_grab()
		else:
			_do_snap_grab()
	elif _active_grab_point:
		_do_snap_grab()
	else:
		_do_precise_grab()

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
		_highlight_requests.erase(from)

	# Update the highlighted state
	_highlighted = _highlight_requests.size() > 0

	# Report any changes
	if _highlighted != old_highlighted:
		if _highlighted: # If highlight is on and new, rumble controller
			if from is XRToolsFunctionPickup:
				rumble(from)
		emit_signal("highlight_updated", self, _highlighted)



### Events ###

func _on_exit_box(area : Area3D):
	if area == in_box and area != desktop:
		tangible(TangibleState.INTANGIBLE)

func _on_enter_box(area : Area3D):
	if area == in_box:
		tangible(TangibleState.TANGIBLE)

### Helper ###

func anim_in_list(_name):
	if poke_anim_player:
		var anim_list = poke_anim_player.get_animation_list()
		return _name in anim_list

	return false

func safe_poke_anim_play(_name, backup=""):
	if poke_anim_player:
		if anim_in_list(_name):
			poke_anim_player.play(_name)
		elif anim_in_list(backup):
			poke_anim_player.play(backup)

func cry():
	if id != 0:
		cry_player.play()
		safe_poke_anim_play("animation_"+pokemon_name+"_cry")

func idle():
	safe_poke_anim_play("animation_"+pokemon_name+"_ground_idle", "animation_"+pokemon_name+"_idle")

func _on_let_go_by_controller():
	disable_snap()
	grow()
	pc.adopt(self) ## Re-adopt when dropped

func _on_picked_up_by_ball():
	activate_snap()
	shrink()

	in_box = null

func _on_picked_up_by_controller():
	if copy:
		copy.queue_free()
		copy = null
	
	in_box = desktop
	reparent(desktop.pokemon)

func disable_snap():
	for point in _grab_points:
		point.enabled = false

func activate_snap():
	for point in _grab_points:
		point.enabled = true

func grow():
	if size_state == SizeState.SMALL:
		size_state = SizeState.LARGE
		
		digi_anim_player.play("grow")

func shrink():
	if size_state == SizeState.LARGE:
		size_state = SizeState.SMALL

		digi_anim_player.stop()

		collision.scale = Vector3.ONE
		collision.position = Vector3.UP * POKEBALL_SCALE
		mesh.scale = Vector3.ONE * POKEBALL_SCALE

func set_box(box : Box):
	in_box = box
	
	## Update shader
	for mat in shader_update_list:
		mat.set_shader_parameter("override", !in_box or in_box == desktop)
	
	if tangible_area.overlaps_area(box):
		tangible(TangibleState.TANGIBLE)
	else:
		tangible(TangibleState.INTANGIBLE)

func tangible(_tangible_state : TangibleState):
	tangible_state = _tangible_state

	match tangible_state:
		TangibleState.TANGIBLE:
			visible = true
			collision.set_deferred("disabled", false)
		TangibleState.INTANGIBLE:
			visible = false
			collision.set_deferred("disabled", true)

func apply_shader(node : Node3D):
	## Apply shader to node
	if node is MeshInstance3D:
		## Create mat and get albedo png
		var albedo = node.mesh.surface_get_material(0).albedo_texture
		# var albedo_image = Image.load_from_file(albedo_path)
		# var albedo = ImageTexture.create_from_image(albedo_image)
		var mat = clip_mat.duplicate()
		mat.set_shader_parameter("texture_albedo", albedo)
		mat.set_shader_parameter("override", true)

		## Add mat to shader_update_list
		shader_update_list.append(mat)

		## Add mat back to node as surface override
		node.set_surface_override_material(0, mat)

	## Apply shader to children
	for child in node.get_children():
		if child is Node3D: apply_shader(child)

func rumble(from):
	if picked_up_by: from.get_parent().full_rumble()

func fix_pos(pos, neg):
	var _new_position = global_position

	global_position = _new_position.clamp(neg, pos)
