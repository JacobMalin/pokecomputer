class_name Box
extends Area3D

signal take_priority(box)

@export var color : Color = Color("ad985b")

const MIN_SIZE = 0.1
const PADDING = 0.01 ## To prevent z-fighting

@onready var collision : CollisionShape3D = $Collision
@onready var boxes = $Boxes

@onready var portal : Portal = preload("res://scenes/computer/portal/portal.tscn").instantiate()
@onready var world_in_cube : WorldInCube = preload("res://scenes/computer/box/world_in_cube.tscn").instantiate()
@onready var portal_reference : Node3D = world_in_cube.get_node("LeftPortalViewport/PortalReference")
@onready var camera : Camera3D = world_in_cube.get_node("LeftPortalViewport/LeftCamera")

@onready var digi_poke_copy_scene = preload("res://scenes/pokemon/digital_pokemon_copy.tscn")

@onready var orig_position : Vector3 = global_position


enum BoxMode {
	MAXIMIZED,
	MINIMIZED
}
var box_mode : BoxMode = BoxMode.MAXIMIZED

var corners : Corners
var portal_ref_mesh : MeshInstance3D
var pokemon : Node3D
var pokemon_copies : Node3D
var world_pickable : WorldPickable
var minimized : MinimizedBox
var copy_copy : Node3D

var saved_pos : Vector3
var single_click : Area3D

### Lifecycle ###

func _ready():
	corners = $Corners
	portal_ref_mesh = $PortalReferenceMesh
	pokemon = $Pokemon
	pokemon_copies = world_in_cube.get_node("LeftPortalViewport/PokemonCopies")
	world_pickable = $WorldPickable
	minimized = $MinimizedBox

	for box in get_children_boxes():
		box.take_priority.connect(_on_take_priority)
	
	# Init world-in-cube and portal
	world_in_cube.color = color

	portal.camera_reference = world_in_cube

	get_tree().get_root().add_child.call_deferred(world_in_cube)
	add_child(portal)

	## Hide minimize cube
	minimized.disable()

	## Link events
	world_pickable.world_move.connect(_on_world_move)
	world_pickable.world_move.connect(_on_world_accumulate)
	world_pickable.world_move.connect(world_in_cube._on_world_move)
	world_pickable.world_accumulate.connect(world_in_cube._on_world_accumulate)

func _process(_delta):
	if box_mode == BoxMode.MINIMIZED: 
		minimized.fix_pos(get_parent_box().get_pos_corner(), get_parent_box().get_neg_corner(), PADDING)
	elif box_mode == BoxMode.MAXIMIZED:
		global_position = corners.get_center()

		# Update size
		portal.mesh.size = corners.get_size()
		portal.global_position = global_position

		# Update collision to match
		collision.shape.size = portal.mesh.size
		collision.global_position = global_position
		
		# Update portal reference mesh to match
		portal_ref_mesh.mesh.size = portal.mesh.size
		portal_ref_mesh.global_position = global_position
		
		# Update minimized box pos to match
		set_minimized_position(global_position)
		
		# Update portal reference to match
		portal_reference.mesh.size = portal.mesh.size
		world_in_cube._on_portal_move(global_position, orig_position)

		# Update digimon position
		for poke in get_children_pokemon():
			if poke is DigitalPokemon:
				poke.update_pos_to_copy(global_position)

func _on_corner_move():
	# Take priority
	take_priority.emit(self)

	# Update children boxes
	for box in get_children_boxes():
		box.check_bounds()

func _on_take_priority(child):
	boxes.move_child(child, 0)

	# Take priority for self
	take_priority.emit(self)

func _on_panel_press(panel : String, location : Area3D, _position : Vector3):
	if location == self:
		match panel:
			"add": add(_position)
			"minimize": minimize()
			"delete": delete()

		return true

	for box in get_children_boxes():
		if box._on_panel_press(panel, location, _position): return true
	
	return false

func _on_world_move(_new_pos):
	# Update digimon position
	for poke in get_children_pokemon():
		if poke is DigitalPokemon:
			poke.update_pos_to_copy.call_deferred(portal.global_position)

func _on_world_accumulate(_accumulated_position):
	# Update digimon position
	for poke in get_children_pokemon():
		if poke is DigitalPokemon:
			poke.update_pos_to_copy.call_deferred(portal.global_position)



### Helper ###

func in_bounds(poke : DigitalPokemon):
	return overlaps_body(poke)

func adopt(poke : DigitalPokemon):
	if not in_bounds(poke): return false

	for box in get_children_boxes():
		if box.adopt(poke): return true

	adopt_to_specific(poke)

	return true

func adopt_to_specific(poke):
	poke.set_box(self)
	poke.reparent(pokemon)

	## Copy digital pokemon
	var digi_poke_copy : DigitalPokemonCopy = digi_poke_copy_scene.instantiate()
	digi_poke_copy.copy_of = poke
	digi_poke_copy.portal = portal
	digi_poke_copy.portal_reference = portal_reference
	digi_poke_copy.camera = camera

	poke.copy = digi_poke_copy

	pokemon_copies.add_child(digi_poke_copy)

func power(on : bool):
	if on: 
		if box_mode == BoxMode.MAXIMIZED: portal.show()
		
		for orphan in world_in_cube.orphanage.get_children():
			if orphan is DigitalPokemon:
				orphan.reparent(pokemon)
			elif orphan is MinimizedBox:
				orphan.reparent(self)
				orphan.set_minimized_position(saved_pos)
				
	else:
		saved_pos = minimized.global_position
		
		portal.hide()
		
		for poke in get_children_pokemon():
			poke.reparent(world_in_cube.orphanage)
		minimized.reparent(world_in_cube.orphanage)
	
	for box in get_children_boxes():
		box.power(on)
	
	corners.power(on)

func get_children_boxes():
	return boxes.get_children()

func get_parent_box():
	return get_parent().get_parent()

func add(add_pos):	
	# instantiate new child box inside the current box
	var new_box = load("res://scenes/computer/box/box.tscn").instantiate()
	new_box.color = Color(randf(), randf(), randf())

	boxes.add_child(new_box)

	# start added box in minimized mode
	new_box.set_minimized_position(add_pos)
	new_box.box_modes(BoxMode.MINIMIZED)

func minimize():	
	box_modes(BoxMode.MINIMIZED)
	
func delete():
	# relocate any pokemon in a deleted box to its parent box
	for poke in get_children_pokemon_recursive():
		get_parent_box().adopt_to_specific(poke)

	world_in_cube.queue_free()

	queue_free()

# Define the different modes of the Box
func box_modes(_box_mode):
	box_mode = _box_mode
	
	match box_mode:
		BoxMode.MAXIMIZED:
			minimized.disable()

			global_position = minimized.global_position
			corners._on_maximize(minimized.global_position)
			check_bounds()

			if copy_copy:
				copy_copy.queue_free()
				copy_copy = null
			
			portal_ref_mesh.show()
			portal.show()
			boxes.show()
			pokemon.show()
			corners.enable()
			world_pickable.enable()
			collision.set_deferred("disabled", false)

			for box in get_children_boxes():
				if box.box_mode == BoxMode.MINIMIZED: box.minimized.enable()
			
		BoxMode.MINIMIZED:
			minimized.enable()

			copy_copy = pokemon_copies.duplicate()
			minimized.add_child(copy_copy)
			copy_copy.scale = Vector3.ONE * 0.04
			copy_copy.position = minimized.global_position * 0.04
			
			portal_ref_mesh.hide()
			portal.hide()
			boxes.hide()
			pokemon.hide()
			corners.disable()
			world_pickable.disable()
			collision.set_deferred("disabled", true)

			for box in get_children_boxes():
				box.box_modes(BoxMode.MINIMIZED)
				box.minimized.disable()

func refresh_click():
	single_click = null

# Maximize box if it is pressed
func _on_minimized_box_area_entered(area):
	if area.is_in_group("index"): 
		if box_mode == BoxMode.MINIMIZED: area.rumble()

		if single_click and single_click == area:
			box_modes(BoxMode.MAXIMIZED)
			single_click = null
		else:
			single_click = area
			$MinimizedBox/AnimationPlayer.play("double_click")

func set_minimized_position(new_pos):
	minimized.set_minimized_position(new_pos)

func get_pos_corner():
	return corners.get_pos_corner()

func get_neg_corner():
	return corners.get_neg_corner()

func check_bounds():
	corners.check_bounds()

func get_children_pokemon():
	return pokemon.get_children()

func get_children_pokemon_recursive():
	var poke_list = []
	
	for box in get_children_boxes():
		poke_list += box.get_children_pokemon_recursive()

	poke_list += pokemon.get_children()

	return poke_list
