class_name DigitalPokemon
extends XRToolsPickable

const POKEBALL_SCALE = 0.03

@export var id: int = 0
var pokemon_name: String

enum State {
	HOLSTER,
	DIGITAL
}
@export var capture_state : State = State.HOLSTER

@onready var globals = get_node("/root/Globals")
@onready var collision: CollisionShape3D = $Collision
@onready var audio_player: AudioStreamPlayer3D = $Audio

var animation_player: AnimationPlayer

var pokemon_cry

## Lifecycle ##

func _ready():
	pokemon_name = globals.pokedex[id]

	## Attach model based on id
	var pokemon_scene = load("res://assets/pokemon/scenes/"+pokemon_name+".tscn")
	var pokemon_instance = pokemon_scene.instantiate()

	pokemon_instance.scale = Vector3.ONE * POKEBALL_SCALE

	add_child(pokemon_instance)

	## Load cry based on id
	pokemon_cry = load("res://assets/pokemon/cries/"+pokemon_name+".mp3")
	audio_player.stream = pokemon_cry

	animation_player = pokemon_instance.get_node("AnimationPlayer")

	idle()

func _process(_delta):
	pass


## Events ##



## Helper ##

func cry():
	if id != 0:
		audio_player.play()
		if animation_player: animation_player.play("animation_"+pokemon_name+"_cry")

func idle():
	if animation_player: animation_player.play("animation_"+pokemon_name+"_ground_idle")
