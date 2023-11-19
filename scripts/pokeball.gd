class_name Pokeball
extends XRToolsPickable

const POKE_SCAN_RANGE = 10
const RISE_SPEED = 1
const DROP_TIME = 0.5

const EMPTY = null
@export var contents : Pokemon = EMPTY;
var contents_parent

enum PokeballState {
	DEFAULT,
	PRIMED,
	RISE,
	HOLD,
	DROP
}
@export var mode : PokeballState = PokeballState.DEFAULT;
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var mesh: Node3D = $Mesh
@onready var capture_radius: Area3D = $PokemonCaptureRadius

@onready var player_body: XRToolsPlayerBody = %PlayerBody

var closest_pokemon

var drop_elapsed = 0
var drop_start_rot

## Lifecycle ##

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func _process(delta):
	if mode == PokeballState.RISE: # Look at target
		# Maybe fix some year: Pokeball snaps into place once rise starts

		# Get target for look at
		var target_position;
		if contents == EMPTY and closest_pokemon != null: ## Look at the closest pokemon in a range of POKE_SCAN_RANGE
			target_position = closest_pokemon.get_node("CollisionShape3D").global_position
		else: ## Look at ground 1 meter away from ball in the direction away from the player
			target_position = release_position()
		
		# Look at target
		mesh.look_at(target_position)
		mesh.rotate_object_local(Vector3.UP, PI)

	if mode == PokeballState.DROP: # Reset rotation
		if drop_elapsed >= DROP_TIME:
			mode = PokeballState.DEFAULT
			mesh.rotation = Vector3.ZERO

		drop_elapsed += delta

		var intermediate_rot = drop_start_rot.lerp(Vector3.ZERO, drop_elapsed / DROP_TIME)
		mesh.rotation = intermediate_rot

func _integrate_forces(state):
	# Rise upwards
	if mode == PokeballState.RISE:
		state.linear_velocity = Vector3.UP * 0.01 / state.step
		state.angular_velocity = Vector3.ZERO


## Events ##

func _on_pokeball_hit_something(body:Node):
	var all_pokeballs = get_tree().get_nodes_in_group("pokeball")
	if body in all_pokeballs or mode != PokeballState.PRIMED: # Don't hit itself and do not activate until primed
		return

	print(body.name)

	# This controls many things, but essentially drives the pokemon capture/release
	animation_player.play("capture_and_release")

func _on_pokeball_dropped(_pickable):
	mode = PokeballState.PRIMED



## Helper ##

### RISE phase ###

func scan(): # If pokeball is empty, choose closest pokemon to capture
	if contents == EMPTY:
		var all_pokemon = get_tree().get_nodes_in_group("pokemon")
		var can_be_captured = (func(poke): return poke in all_pokemon and poke.capture_state == poke.PokemonCapture.FREE)
		var nearby_pokemon = capture_radius.get_overlapping_bodies().filter(can_be_captured)

		closest_pokemon = nearby_pokemon.reduce(func(_min, poke): return poke if is_closer(poke, _min) else _min)

		# If there is a free pokemon nearby, mark as pre_captured
		if closest_pokemon: closest_pokemon.pre_capture()

func is_closer(poke, _min):
	return poke.global_position.distance_squared_to(global_position) < \
		   _min.global_position.distance_squared_to(global_position)

### HOLD phase ###

func capture_and_release():
	if contents == EMPTY: capture()
	else: release()

func capture():
	if closest_pokemon == null: # If no pokemon was found in the scan phase
		$AnimationPlayer.stop()
		mode = PokeballState.DROP
		collision.disabled = false
		enabled = true

		drop_start()
		return
	
	# Monch pokemon
	contents = closest_pokemon

	contents_parent = contents.get_parent()
	contents.reparent(self)

	# I do not like this rotate_object_local solution and I would fix it if I could, but
	# unfortunately I do not understand the math well enough to do it using matrices
	mesh.rotate_object_local(Vector3.UP, PI)
	contents.capture(mesh.global_rotation)
	mesh.rotate_object_local(Vector3.UP, PI)

func release():
	contents.reparent(contents_parent)
	
	# Same as capture, would fix if I could. Start and end rotation is the same currently.
	mesh.rotate_object_local(Vector3.UP, PI)
	contents.release(release_position(), mesh.global_rotation, mesh.global_rotation)
	mesh.rotate_object_local(Vector3.UP, PI)

	contents = EMPTY

# A position on the ground 1 meter away from ball in the direction of the player
func release_position():
	var player_to_ball = global_position - player_body.global_position
	player_to_ball.y = 0
	var dir = -player_to_ball.normalized()

	return (global_position + dir) * Vector3(1, 0, 1)

### DROP phase ###

func drop_start():
	drop_elapsed = 0
	drop_start_rot = mesh.rotation
