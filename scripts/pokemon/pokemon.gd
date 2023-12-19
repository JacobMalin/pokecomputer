class_name Pokemon
extends CharacterBody3D

const MOVEMENT_SPEED: float = 1.0
const MIN_ANGLE: float = 30. / 180 * PI

const ROTATE_SPEED: float = 1.0
const ROTATION_NUDGE_BIAS: float = 0.5

const RANDOM_DEST_DIST: float = 10.0

const CAPTURE_TIME = 1.0
const RELEASE_TIME = 1.0
const POKEBALL_SCALE = 0.03

@export var id: int = 0
var pokemon_name: String

enum MoveState {
	IDLE,
	WALK
}
@export var move_state : MoveState = MoveState.WALK

enum CaptureState {
	FREE,
	PRE_CAPTURE,
	CAPTURE,
	CONTAIN,
	RELEASE
}
@export var capture_state : CaptureState = CaptureState.FREE

@onready var globals = get_node("/root/Globals")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var animation_player: AnimationPlayer

var pokemon_cry

var capture_elapsed = 0
var capture_start_pos
var capture_dest_pos
var capture_start_rot
var capture_dest_rot

var release_elapsed = 0
var release_start_pos
var release_dest_pos
var release_start_rot
var release_dest_rot

## Lifecycle ##

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	pokemon_name = globals.pokedex[id]

	## Remove placeholder bulbasaur model
	$Placeholder.queue_free()

	## Attach model based on id
	var pokemon_scene = load("res://assets/pokemon/scenes/"+pokemon_name+".tscn")
	var pokemon_instance = pokemon_scene.instantiate()
	add_child(pokemon_instance)

	## Load cry based on id
	pokemon_cry = load("res://assets/pokemon/cries/"+pokemon_name+".mp3")
	audio_player.stream = pokemon_cry

	if pokemon_instance.has_node("AnimationPlayer"):
		animation_player = pokemon_instance.get_node("AnimationPlayer")

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished() || move_state != MoveState.WALK:
		return
		
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = next_path_position - current_agent_position
	direction = direction.normalized()

	# Nudge prevents them from going in circles
	velocity = (-global_transform.basis.z + direction * ROTATION_NUDGE_BIAS).normalized() * MOVEMENT_SPEED

	move_and_slide()

	if not direction.is_equal_approx(Vector3.ZERO):
		## Rotation code adapted from https://www.reddit.com/r/godot/comments/coy5e8/pathfinding_how_to_rotate_my_unit_towards_the/
		## Error prevention adapted from https://github.com/godotengine/godot/issues/79146
		var lookatpos = global_transform.origin + direction
		var v_z : Vector3 = (lookatpos - Vector3.UP).normalized()
		var v_x : Vector3 = Vector3.UP.cross(-v_z)

		if not lookatpos.is_equal_approx(Vector3.UP) and not v_x.is_zero_approx():
			var l = global_transform.looking_at(lookatpos, Vector3.UP)
			var start = Quaternion(global_transform.basis.orthonormalized())
			var goal = Quaternion(l.basis)
			var final = start.slerp(goal, ROTATE_SPEED * delta)
			global_transform.basis = Basis(final)

func _process(delta):
	if capture_state == CaptureState.CAPTURE:
		if capture_elapsed >= CAPTURE_TIME:
			position = capture_dest_pos
			rotation = Vector3.UP * PI # final rotation is aligned with rigid body, not mesh
			scale = Vector3.ONE * POKEBALL_SCALE

			end_capture()

			return
		
		capture_elapsed += delta

		# position
		var intermediate_pos = capture_start_pos.lerp(capture_dest_pos, capture_elapsed / CAPTURE_TIME)
		position = intermediate_pos

		# rotation
		var intermediate_rot = capture_start_rot.lerp(capture_dest_rot, capture_elapsed / CAPTURE_TIME)
		global_rotation = intermediate_rot

		# size
		var intermediate_size = Vector3.ONE.lerp(Vector3.ONE * POKEBALL_SCALE, capture_elapsed / CAPTURE_TIME)
		scale = intermediate_size

	if capture_state == CaptureState.RELEASE:
		if release_elapsed >= RELEASE_TIME:
			global_position = release_dest_pos
			global_rotation = release_dest_rot
			scale = Vector3.ONE

			end_release()

			return
		
		release_elapsed += delta

		# position
		var intermediate_pos = release_start_pos.lerp(release_dest_pos, release_elapsed / RELEASE_TIME)
		global_position = intermediate_pos

		# rotation
		var intermediate_rot = release_start_rot.lerp(release_dest_rot, release_elapsed / RELEASE_TIME)
		global_rotation = intermediate_rot

		# size
		var intermediate_size = (Vector3.ONE * POKEBALL_SCALE).lerp(Vector3.ONE, release_elapsed / RELEASE_TIME)
		scale = intermediate_size


## Events ##

func _on_navigation_agent_3d_navigation_finished():
	if move_state == MoveState.WALK:
		walk()



## Helper ##
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	if move_state == MoveState.WALK: walk()
	if move_state == MoveState.IDLE: idle()

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func clear_movement_target():
	set_movement_target(global_position)

func cry():
	audio_player.play()
	safe_anim_queue("animation_"+pokemon_name+"_cry")

func is_free():
	return capture_state == CaptureState.FREE

func anim_in_list(_name):
	if animation_player:
		var anim_list = animation_player.get_animation_list()
		return _name in anim_list

	return false

func safe_anim_play(_name, backup=""):
	if animation_player:
		if anim_in_list(_name):
			animation_player.play(_name)
		elif anim_in_list(backup):
			animation_player.play(backup)

func safe_anim_queue(_name, backup=""):
	if animation_player:
		if anim_in_list(_name):
			animation_player.queue(_name)
		elif anim_in_list(backup):
			animation_player.queue(backup)

### Pokemon move states ###

func walk():
	if id != 0 and anim_in_list("animation_"+pokemon_name+"_ground_walk"):
		move_state = MoveState.WALK
		safe_anim_play("animation_"+pokemon_name+"_ground_walk")
		set_movement_target(Vector3(randf_range(-RANDOM_DEST_DIST, RANDOM_DEST_DIST),
									0.0,
									randf_range(-RANDOM_DEST_DIST, RANDOM_DEST_DIST)))

func idle():
	if id != 0:
		move_state = MoveState.IDLE
		safe_anim_play("animation_"+pokemon_name+"_ground_idle", "animation_"+pokemon_name+"_idle")
		clear_movement_target()

### Pokemon capture states ###

## Marks pokemon as not available to capture
func pre_capture():
	capture_state = CaptureState.PRE_CAPTURE

func capture(dest_rot):
	capture_state = CaptureState.CAPTURE
	capture_elapsed = 0
	
	capture_start_pos = position
	capture_dest_pos  = Vector3(0, -.02, 0)

	capture_start_rot = global_rotation
	capture_dest_rot = dest_rot

	collision.disabled = true

	idle()

func end_capture():
	capture_state = CaptureState.CONTAIN

func release(dest_pos, start_rot, dest_rot):
	capture_state = CaptureState.RELEASE
	release_elapsed = 0
	
	release_start_pos = global_position
	release_dest_pos  = dest_pos

	release_start_rot = start_rot
	release_dest_rot  = dest_rot

	cry()

func end_release():
	capture_state = CaptureState.FREE
	collision.disabled = false

	walk()
