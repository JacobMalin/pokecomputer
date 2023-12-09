class_name Pokeball
extends XRToolsPickable

const POKE_SCAN_RANGE = 10
const RISE_SPEED = 1
const DROP_TIME = 0.5
const POKEBALL_SCALE = 0.03


@onready var pokemon_scene = preload("res://scenes/pokemon.tscn")
@onready var digital_scene = preload("res://scenes/digital_pokemon.tscn")

const red_materials = {
	DisplayState.DEFAULT: preload("res://assets/pokeball/pokeball_top_material_default.tres"),
	DisplayState.HOLSTER: preload("res://assets/pokeball/pokeball_top_material_holster.tres"),
	DisplayState.DIGITAL: preload("res://assets/pokeball/pokeball_top_material_digital.tres"),
}

enum CaptureState {
	DEFAULT,
	PRIMED,
	RISE,
	HOLD,
	DROP
}
@export var capture_state : CaptureState = CaptureState.DEFAULT

enum DisplayState {
	DEFAULT,
	HOLSTER,
	DIGITAL
}
@export var display_state : DisplayState = DisplayState.DEFAULT

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var mesh: Node3D = $Mesh
@onready var capture_radius: Area3D = $PokemonCaptureRadius
@onready var digi_snap: DigiPokeSnap = $DigiPokeSnap

@onready var sphere_mesh = mesh.get_node("Sphere")

@onready var player_body: XRToolsPlayerBody = %PlayerBody
@onready var holster: Holster = %Holster
@onready var computer: Computer = %Computer
@onready var pokemon_node: Node3D = %Pokemon


const EMPTY = null
var contents : DigitalPokemon = EMPTY
var contents_temp : Pokemon = EMPTY

var closest_pokemon

var drop_elapsed = 0
var drop_start_rot

## Lifecycle ##

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func _process(delta):
	if capture_state == CaptureState.RISE: # Look at target
		# Maybe fix some year: Pokeball snaps into place once rise starts

		# Get target for look at
		var target_position
		if contents == EMPTY and closest_pokemon != null: ## Look at the closest pokemon in a range of POKE_SCAN_RANGE
			target_position = closest_pokemon.get_node("CollisionShape3D").global_position
		else: ## Look at ground 1 meter away from ball in the direction away from the player
			target_position = release_position()
		
		# Look at target
		mesh.look_at(target_position)
		mesh.rotate_object_local(Vector3.UP, PI)

	if capture_state == CaptureState.DROP: # Reset rotation
		if drop_elapsed >= DROP_TIME:
			capture_state = CaptureState.DEFAULT
			mesh.rotation = Vector3.ZERO

		drop_elapsed += delta

		var intermediate_rot = drop_start_rot.lerp(Vector3.ZERO, drop_elapsed / DROP_TIME)
		mesh.rotation = intermediate_rot

func _integrate_forces(state):
	# Rise upwards
	if capture_state == CaptureState.RISE:
		state.linear_velocity = Vector3.UP * 0.01 / state.step
		state.angular_velocity = Vector3.ZERO


## Events ##

func _on_pokeball_hit_something(body:Node):
	var all_pokeballs = get_tree().get_nodes_in_group("pokeball")
	if body in all_pokeballs or capture_state != CaptureState.PRIMED: # Don't hit itself and do not activate until primed
		return

	# This controls many things, but essentially drives the pokemon capture/release
	animation_player.play("capture_and_release")

func _on_pokeball_dropped(_pickable):
	capture_state = CaptureState.PRIMED

func _on_digi_snap_has_dropped():
	computer.adopt(contents)
	contents = EMPTY

func _on_digi_snap_has_picked_up(what):
	contents = what



## Helper ##

func enter_computer():
	if display_state == DisplayState.HOLSTER:
		display(DisplayState.DIGITAL)

func exit_computer():
	if display_state == DisplayState.DIGITAL:
		display(DisplayState.HOLSTER)

func enter_holster():
	display(DisplayState.HOLSTER)
	capture_state = CaptureState.DEFAULT

func exit_holster():
	display(DisplayState.DEFAULT)

func display(_display_state):
	display_state = _display_state
	
	sphere_mesh.mesh.surface_set_material(0, red_materials[display_state])

	match display_state:
		DisplayState.DEFAULT:
			mesh.visible = true
			enabled = true
			collision.disabled = false
			digi_snap.enabled = false
		DisplayState.HOLSTER:
			mesh.visible = true
			enabled = true
			collision.disabled = false
			digi_snap.enabled = false
		DisplayState.DIGITAL:
			mesh.visible = false
			enabled = false
			collision.disabled = true
			digi_snap.enabled = true


### RISE phase ###

func scan(): # If pokeball is empty, choose closest pokemon to capture
	if contents == EMPTY:
		var all_pokemon = get_tree().get_nodes_in_group("pokemon")
		var can_be_captured = (func(poke): return poke in all_pokemon and poke.is_free())
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
		capture_state = CaptureState.DROP
		collision.disabled = false
		enabled = true

		drop_start()
		return
	
	# Monch pokemon
	contents_temp = closest_pokemon

	contents_temp.reparent(self)

	# I do not like this rotate_object_local solution and I would fix it if I could, but
	# unfortunately I do not understand the math well enough to do it using matrices
	mesh.rotate_object_local(Vector3.UP, PI)
	contents_temp.capture(mesh.global_rotation)
	mesh.rotate_object_local(Vector3.UP, PI)

func release():
	# Undigitize pokemon
	var contents_id = contents.id
	contents.queue_free()

	var pokemon_instance = pokemon_scene.instantiate()

	pokemon_instance.id = contents_id
	pokemon_instance.global_position = global_position
	pokemon_instance.scale = Vector3.ONE * POKEBALL_SCALE

	pokemon_node.add_child(pokemon_instance)
	
	# Same as capture, would fix if I could. Start and end rotation is the same currently.
	mesh.rotate_object_local(Vector3.UP, PI)
	pokemon_instance.release(release_position(), mesh.global_rotation, mesh.global_rotation)
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

	# Since capture has finished, digitize the pokemon
	if contents_temp != EMPTY:
		var contents_id = contents_temp.id
		contents_temp.queue_free()

		contents = digital_scene.instantiate()

		contents.id = contents_id

		add_child(contents)

		digi_snap.pick_up_object(contents)




