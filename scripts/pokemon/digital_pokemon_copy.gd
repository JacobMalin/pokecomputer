class_name DigitalPokemonCopy
extends Node3D

@export var copy_of : DigitalPokemon
var portal
var portal_reference

var pokemon_name

var mesh
var poke_anim_player: AnimationPlayer

@onready var digi_anim_player: AnimationPlayer = $AnimationPlayer

## Lifecycle ##

func _ready():
	pokemon_name = copy_of.pokemon_name

	## Attach model based on id
	var pokemon_scene = load("res://assets/pokemon/scenes/"+pokemon_name+".tscn")
	mesh = pokemon_scene.instantiate()

	mesh.name = "Mesh"
	mesh.scale = copy_of.mesh.scale

	var portal_to_poke = copy_of.global_position - portal.global_position
	global_position = portal_reference.global_position + portal_to_poke
	global_rotation = copy_of.global_rotation

	add_child(mesh)

	poke_anim_player = mesh.get_node("AnimationPlayer")

	# Sync idle
	idle()
	poke_anim_player.seek(copy_of.poke_anim_player.get_current_animation_position(), true)

	# Sync grow
	var copy_anim_name = copy_of.digi_anim_player.current_animation
	print(copy_anim_name)
	if copy_anim_name:
		digi_anim_player.play(copy_anim_name)
		digi_anim_player.seek(copy_of.digi_anim_player.get_current_animation_position(), true)



## Helper ##

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

func idle():
	safe_poke_anim_play("animation_"+pokemon_name+"_ground_idle", "animation_"+pokemon_name+"_idle")

func grow():
	digi_anim_player.play("grow")
