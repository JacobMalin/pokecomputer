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

@onready var globals = get_node("/root/Globals")
@onready var collision: CollisionShape3D = $Collision
@onready var cry_player: AudioStreamPlayer3D = $CryPlayer
@onready var digi_anim_player: AnimationPlayer = $AnimationPlayer

var mesh
var poke_anim_player: AnimationPlayer

## Lifecycle ##

func _ready():
	super._ready()

	pokemon_name = globals.pokedex[id]

	## Attach model based on id
	var pokemon_scene = load("res://assets/pokemon/scenes/"+pokemon_name+".tscn")
	mesh = pokemon_scene.instantiate()

	mesh.name = "Mesh"
	mesh.scale = Vector3.ONE * POKEBALL_SCALE

	add_child(mesh)

	## Load cry based on id
	var pokemon_cry = load("res://assets/pokemon/cries/"+pokemon_name+".mp3")
	cry_player.stream = pokemon_cry

	poke_anim_player = mesh.get_node("AnimationPlayer")

	idle()

func _process(_delta):
	pass


### Events ###



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
		_on_let_go() ## This line is new

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



## Helper ##

func safe_poke_anim_play(_name):
	if poke_anim_player:
		var anim_list = poke_anim_player.get_animation_list()
		if _name in anim_list:
			poke_anim_player.play(_name)

func cry():
	if id != 0:
		cry_player.play()
		safe_poke_anim_play("animation_"+pokemon_name+"_cry")

func idle():
	safe_poke_anim_play("animation_"+pokemon_name+"_ground_idle")

func _on_let_go():
	disable_snap()
	grow()

func _on_picked_up_by_ball():
	activate_snap()
	shrink()

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
