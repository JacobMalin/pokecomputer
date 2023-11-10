extends CharacterBody3D

const MOVEMENT_SPEED: float = 1.0
const movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)
const MIN_ANGLE: float = 30. / 180 * PI

const ROTATE_SPEED: float = 1.0
const ROTATION_NUDGE_BIAS: float = 0.5

const RANDOM_DEST_DIST: float = 4.0

@export var pokemon_id: int = 0
var pokemon_name

@onready var globals = get_node("/root/Globals")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var animation_player: AnimationPlayer

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	pokemon_name = globals.pokedex[pokemon_id]

	var pokemon_scene = load("res://assets/pokemon/scenes/"+pokemon_name+".tscn")
	var pokemon_instance = pokemon_scene.instantiate()
	add_child(pokemon_instance)

	animation_player = pokemon_instance.get_node("AnimationPlayer")

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)
	animation_player.play("animation_"+pokemon_name+"_ground_walk")

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

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


func _on_navigation_agent_3d_navigation_finished():
	# animation_player.play("animation_bulbasaur_ground_idle")
	# await get_tree().create_timer(1).timeout
	# animation_player.play("animation_bulbasaur_ground_walk")
	set_movement_target(Vector3(randf_range(-RANDOM_DEST_DIST, RANDOM_DEST_DIST),
								0.0,
								randf_range(-RANDOM_DEST_DIST, RANDOM_DEST_DIST)))
	pass
