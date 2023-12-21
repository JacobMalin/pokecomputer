class_name DigitalPokemonCopy
extends Node3D

@export var copy_of : DigitalPokemon
@export var portal : Portal
@export var portal_reference : MeshInstance3D
@export var camera : Camera3D

var pokemon_name

var mesh
var poke_anim_player: AnimationPlayer

@onready var digi_anim_player: AnimationPlayer = $AnimationPlayer
@onready var clip_mat = preload("res://assets/computer/box/clip_material.tres")

var shader_update_list = []

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

	apply_shader(mesh)
	add_child(mesh)

	poke_anim_player = mesh.get_node("AnimationPlayer")

	# Sync idle
	if pokemon_name != "substitute":
		idle()
		poke_anim_player.seek(copy_of.poke_anim_player.get_current_animation_position(), true)

	# Sync grow
	var copy_anim_name = copy_of.digi_anim_player.current_animation

	if copy_anim_name:
		digi_anim_player.play(copy_anim_name)
		digi_anim_player.seek(copy_of.digi_anim_player.get_current_animation_position(), true)

func _process(_delta):
	var pos = portal_reference.global_position + portal_reference.mesh.size / 2
	var neg = portal_reference.global_position - portal_reference.mesh.size / 2

	for mat in shader_update_list:
		mat.set_shader_parameter("pos", pos)
		mat.set_shader_parameter("neg", neg)
		mat.set_shader_parameter("w_cam", camera.global_position)



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

func apply_shader(node : Node3D):
	## Apply shader to node
	if node is MeshInstance3D:
		## Create mat and get albedo png
		var albedo = node.mesh.surface_get_material(0).albedo_texture
		# var albedo_image = Image.load_from_file(albedo_path)
		# var albedo = ImageTexture.create_from_image(albedo_image)
		var mat = clip_mat.duplicate()
		mat.set_shader_parameter("texture_albedo", albedo)

		## Add mat to shader_update_list
		shader_update_list.append(mat)

		## Add mat back to node as surface override
		node.set_surface_override_material(0, mat)

	## Apply shader to children
	for child in node.get_children():
		if child is Node3D: apply_shader(child)

func get_ref_to_copy():
	return global_position - portal_reference.global_position
