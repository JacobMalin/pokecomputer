class_name Pokeball
extends XRToolsPickable

const POKE_SCAN_RANGE = 10
const RISE_SPEED = 1
const DROP_TIME = 0.5
const POKEBALL_SCALE = 0.03


@onready var pokemon_scene = preload("res://scenes/pokemon/pokemon.tscn")
@onready var digital_scene = preload("res://scenes/pokemon/digital_pokemon.tscn")

const red_materials = {
	DisplayState.DEFAULT: preload("res://assets/pokeball/materials/pokeball_red_default.tres"),
	DisplayState.HOLSTER: preload("res://assets/pokeball/materials/pokeball_red_holster.tres"),
	DisplayState.DIGITAL: preload("res://assets/pokeball/materials/pokeball_red_digital.tres"),
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

@onready var catch_audio = $CatchSound
@onready var release_audio = $ReleaseSound

@onready var sphere_mesh = mesh.get_node("Sphere")

@onready var player_body: XRToolsPlayerBody = %PlayerBody
@onready var holster: Holster = %Holster
@onready var pc: PC = %PC
@onready var pokemon_node: Node3D = %Pokemon


const EMPTY = null
var contents : DigitalPokemon = EMPTY
var contents_temp : Pokemon = EMPTY

var closest_pokemon

var drop_elapsed = 0
var drop_start_rot

## Lifecycle ##

func _ready():
	super._ready()

# Controlls and animates pokeball rise and drop
func _process(delta):
	if capture_state == CaptureState.RISE: # Look at target
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

# Animates pokeball rise
func _integrate_forces(state):
	# Rise upwards
	if capture_state == CaptureState.RISE:
		state.linear_velocity = Vector3.UP * 0.01 / state.step
		state.angular_velocity = Vector3.ZERO


## Super Overrides ##

# Add rumble call when highlighted by controller
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


## Events ##

# When pokeball hits surface and is primed, starts pokeball capture/release animation
func _on_pokeball_hit_something(body:Node):
	var all_pokeballs = get_tree().get_nodes_in_group("pokeball")
	if body in all_pokeballs or capture_state != CaptureState.PRIMED: # Don't hit itself and do not activate until primed
		return

	# This controls many things, but essentially drives the pokemon capture/release
	animation_player.play("capture_and_release")

# When pokeball is dropped by a controller, prime the pokeball for capture/release
func _on_pokeball_dropped(_pickable):
	capture_state = CaptureState.PRIMED

# When pokeball is picked up by controller, unprime the pokeball
func _on_pokeball_picked_up(_pickable):
	if by_controller:
		capture_state = CaptureState.DEFAULT

# When digital pokemon is taken out of holster reparent digital pokemon from pokeball to pc
func _on_digi_snap_has_dropped():
	contents.reparent(pc)

	contents = EMPTY

# When digital pokemon is placed into holster reparent digital pokemon from pc to pokeball
func _on_digi_snap_has_picked_up(what):
	what.reparent(self)

	contents = what

	contents._on_picked_up_by_ball()



## Helper ##

# When pokeball enters computer, make invisible
func enter_computer():
	if display_state == DisplayState.HOLSTER:
		display(DisplayState.DIGITAL)

# When pokeball exits computer, make semi-transparent
func exit_computer():
	if display_state == DisplayState.DIGITAL:
		display(DisplayState.HOLSTER)

# When pokeball enters holster, make semi-transparent and unprime pokeball
func enter_holster():
	display(DisplayState.HOLSTER)
	capture_state = CaptureState.DEFAULT

# When pokeball exits holster, make opaque
func exit_holster():
	display(DisplayState.DEFAULT)

# Update pokeball mesh transparency and appropriately disable/enable collisions/visibility
func display(_display_state):
	display_state = _display_state
	
	sphere_mesh.mesh.surface_set_material(1, red_materials[display_state])

	match display_state:
		DisplayState.DEFAULT:
			mesh.visible = true
			enabled = true
			collision.set_deferred("disabled", false)
			digi_snap.enabled = false
			if contents: contents.visible = false
		DisplayState.HOLSTER:
			mesh.visible = true
			enabled = true
			collision.set_deferred("disabled", false)
			digi_snap.enabled = false
			if contents: contents.visible = true
		DisplayState.DIGITAL:
			mesh.visible = false
			enabled = false
			collision.set_deferred("disabled", true)
			digi_snap.enabled = true
			if contents: contents.visible = true

# Rumble controller
func rumble(from):
	if contents: from.get_parent().full_rumble()
	else: from.get_parent().empty_rumble()


### RISE phase ###

# If pokeball is empty, choose closest pokemon to capture and mark pokemon as precaptured
func scan():
	if contents == EMPTY:
		var all_pokemon = get_tree().get_nodes_in_group("pokemon")
		var can_be_captured = (func(poke): return poke in all_pokemon and poke.is_free())
		var nearby_pokemon = capture_radius.get_overlapping_bodies().filter(can_be_captured)

		closest_pokemon = nearby_pokemon.reduce(func(_min, poke): return poke if is_closer(poke, _min) else _min)

		# If there is a free pokemon nearby, mark as pre_captured
		if closest_pokemon: closest_pokemon.pre_capture()

# Return if poke is closer than _min
func is_closer(poke, _min):
	return poke.global_position.distance_squared_to(global_position) < \
		   _min.global_position.distance_squared_to(global_position)

### HOLD phase ###

# If empty, start capture, else start release
func capture_and_release():
	if contents == EMPTY: capture()
	else: release()

# Captures the pokemon
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
	
	catch_audio.play()

	contents_temp.reparent(self)

	# I do not like this rotate_object_local solution and I would fix it if I could, but
	# unfortunately I do not understand the math well enough to do it using matrices
	mesh.rotate_object_local(Vector3.UP, PI)
	contents_temp.capture(mesh.global_rotation)
	mesh.rotate_object_local(Vector3.UP, PI)

# Deletes the digital pokemon and reinstantiates and relases the pokemon
func release():
	# Undigitize pokemon
	var contents_id = contents.id
	contents.queue_free()

	var pokemon_instance = pokemon_scene.instantiate()

	pokemon_instance.id = contents_id
	pokemon_instance.scale = Vector3.ONE * POKEBALL_SCALE

	pokemon_node.add_child(pokemon_instance)
	pokemon_instance.global_position = global_position # Must happen after added to tree
	
	release_audio.play()
	
	# Same as capture, would fix if I could. Start and end rotation is the same currently.
	mesh.rotate_object_local(Vector3.UP, PI)
	pokemon_instance.release(release_position(), mesh.global_rotation, mesh.global_rotation)
	mesh.rotate_object_local(Vector3.UP, PI)

	contents = EMPTY

# Returns a position on the ground 1 meter away from ball in the direction of the player
func release_position():
	var player_to_ball = global_position - player_body.global_position
	player_to_ball.y = 0
	var dir = -player_to_ball.normalized()

	return (global_position + dir) * Vector3(1, 0, 1)

### DROP phase ###

# At end of capture, create digital pokemon and delete pokemon
func drop_start():
	drop_elapsed = 0
	drop_start_rot = mesh.rotation

	# Since capture has finished, digitize the pokemon
	if contents_temp != EMPTY:
		var contents_id = contents_temp.id
		contents_temp.queue_free()

		contents = digital_scene.instantiate()

		contents.id = contents_id
		contents.visible = false

		add_child(contents)

		digi_snap.pick_up_object(contents)




