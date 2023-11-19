class_name Pokemon
extends CharacterBody3D

const MOVEMENT_SPEED: float = 1.0
const movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)
const MIN_ANGLE: float = 30. / 180 * PI

const ROTATE_SPEED: float = 1.0
const ROTATION_NUDGE_BIAS: float = 0.5

const RANDOM_DEST_DIST: float = 4.0

const CAPTURE_TIME = 1.0
const RELEASE_TIME = 1.0
const POKEBALL_SCALE = 0.03

@export var id: int = 0
var pokemon_name: String

enum PokemonState {
	IDLE,
	WALK,
	CAPTURE,
	CONTAIN,
	RELEASE
}
@export var mode : PokemonState = PokemonState.WALK

@onready var globals = get_node("/root/Globals")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var animation_player: AnimationPlayer


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

	animation_player = pokemon_instance.get_node("AnimationPlayer")

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
		
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = next_path_position - current_agent_position
	direction = direction.normalized()

	# Nudge prevents them from going in circles
	velocity = (-global_transform.basis.z + direction * ROTATION_NUDGE_BIAS).normalized() * MOVEMENT_SPEED

	move_and_slide()

	## Rotation code adapted from https://www.reddit.com/r/godot/comments/coy5e8/pathfinding_how_to_rotate_my_unit_towards_the/
	var lookatpos = global_transform.origin + direction
	var l = global_transform.looking_at(lookatpos, Vector3(0,1,0))
	var start = Quaternion(global_transform.basis)
	var goal = Quaternion(l.basis)
	var final = start.slerp(goal, ROTATE_SPEED * delta)
	global_transform.basis = Basis(final)

func _process(delta):
	if mode == PokemonState.CAPTURE:
		if capture_elapsed >= CAPTURE_TIME:
			mode = PokemonState.CONTAIN
			position = capture_dest_pos
			rotation = Vector3.UP * PI # final rotation is aligned with rigid body, not mesh
			scale = Vector3.ONE * POKEBALL_SCALE
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

	if mode == PokemonState.RELEASE:
		if release_elapsed >= RELEASE_TIME:
			mode = PokemonState.IDLE
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
	# animation_player.play("animation_bulbasaur_ground_idle")
	# await get_tree().create_timer(1).timeout
	if mode == PokemonState.WALK:
		walk()



## Helper ##
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	walk()

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func clear_movement_target():
	set_movement_target(global_position)

func walk():
	mode = PokemonState.WALK
	animation_player.play("animation_"+pokemon_name+"_ground_walk")
	set_movement_target(Vector3(randf_range(-RANDOM_DEST_DIST, RANDOM_DEST_DIST),
								0.0,
								randf_range(-RANDOM_DEST_DIST, RANDOM_DEST_DIST)))

func idle():
	mode = PokemonState.IDLE
	animation_player.play("animation_"+pokemon_name+"_ground_idle")
	clear_movement_target()

func capture(dest_rot):
	mode = PokemonState.CAPTURE
	capture_elapsed = 0
	
	capture_start_pos = position
	capture_dest_pos  = Vector3(0, -.02, 0)

	capture_start_rot = global_rotation
	capture_dest_rot = dest_rot

	collision.disabled = true

	animation_player.play("animation_"+pokemon_name+"_ground_idle")
	clear_movement_target()

func release(dest_pos, start_rot, dest_rot):
	mode = PokemonState.RELEASE
	release_elapsed = 0
	
	release_start_pos = global_position
	release_dest_pos  = dest_pos

	release_start_rot = start_rot
	release_dest_rot  = dest_rot

func end_release():
	collision.disabled = false

	walk()
