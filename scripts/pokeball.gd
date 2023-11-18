class_name Pokeball
extends Node3D

const POKE_SCAN_RANGE = 10
const RISE_SPEED = 1
const DROP_TIME = 0.5

const EMPTY = null
@export var contents : Pokemon = EMPTY;
var contents_parent

const DEFAULT = 0
const PRIMED = 1
const RISE = 2
const HOLD = 3
const DROP = 4
@export var mode = DEFAULT;
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var rigid_body: RigidBody3D = $Pokeball
@onready var rigid_body_collision: CollisionShape3D = $Pokeball/CollisionShape3D
@onready var rigid_body_mesh: Node3D = $Pokeball/Mesh
@onready var capture_radius: Area3D = $Pokeball/PokemonCaptureRadius

@onready var player_body: XRToolsPlayerBody = %PlayerBody

var closest_pokemon

var drop_elapsed = 0
var drop_start_rot

## Lifecycle ##

# Called when the node enters the scene tree for the first time.
func _ready():
	mode = DEFAULT

	PhysicsServer3D.body_set_force_integration_callback(rigid_body, _rigid_body_integrate_forces)


func _process(delta):
	if mode == RISE: # Look at target
		# Get target for look at
		var target_position;
		if contents == EMPTY and closest_pokemon != null: ## Look at the closest pokemon in a range of POKE_SCAN_RANGE
			target_position = closest_pokemon.get_node("CollisionShape3D").global_position
		else: ## Look at ground 1 meter away from ball in the direction away from the player
			target_position = release_position()
		
		# Look at target
		rigid_body_mesh.look_at(target_position)
		rigid_body_mesh.rotate_object_local(Vector3.UP, PI)

	if mode == DROP: # Reset rotation
		if drop_elapsed >= DROP_TIME:
			mode = DEFAULT
			rigid_body_mesh.rotation = Vector3.ZERO

		drop_elapsed += delta

		var intermediate_rot = drop_start_rot.lerp(Vector3.ZERO, drop_elapsed / DROP_TIME)
		rigid_body_mesh.rotation = intermediate_rot


## Events ##

func _on_pokeball_hit_something(body:Node):
	if body.name == "Pokeball" or mode != PRIMED: # Don't hit itself and do not activate until primed
		return

	# This controls many things, but essentially drives the pokemon capture/release
	animation_player.play("capture_and_release")

func _on_pokeball_picked_up(_pickable):
	mode = PRIMED

func _rigid_body_integrate_forces(state):
	# Rise upwards
	if mode == RISE:
		state.linear_velocity = Vector3.UP * 0.01 / state.step
		state.angular_velocity = Vector3.ZERO



## Helper ##

### RISE phase ###
func scan(): # If pokeball is empty, choose closest pokemon to capture
	if contents == EMPTY:
		var all_pokemon = get_tree().get_nodes_in_group("pokemon")
		var nearby_pokemon = capture_radius.get_overlapping_bodies().filter(func(body): return body in all_pokemon)

		closest_pokemon = nearby_pokemon.reduce(func(_min, poke): return poke if is_closer(poke, _min) else _min)

func is_closer(poke, _min):
	return poke.global_position.distance_squared_to(rigid_body.global_position) < \
		   _min.global_position.distance_squared_to(rigid_body.global_position)

### HOLD phase ###
func capture_and_release():
	if contents == EMPTY: capture()
	else: release()

func capture():
	if closest_pokemon == null: # If no pokemon was found in the scan phase
		$AnimationPlayer.stop()
		mode = DROP
		rigid_body_collision.disabled = false
		rigid_body.enabled = true

		drop_start()
		return
	
	# Monch pokemon
	contents = closest_pokemon

	contents_parent = contents.get_parent()
	contents.reparent(rigid_body)
	contents.capture(self)

func release():
	contents.reparent(contents_parent)
	contents.release(self, release_position())

	contents = EMPTY

func release_position():
	var player_to_ball = rigid_body.global_position - player_body.global_position
	player_to_ball.y = 0
	var dir = player_to_ball.normalized()

	return (rigid_body.global_position + dir) * Vector3(1, 0, 1)

### DROP phase ###
func drop_start():
	drop_elapsed = 0
	drop_start_rot = rigid_body_mesh.rotation
