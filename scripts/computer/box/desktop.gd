class_name Desktop
extends Box

@onready var copy_material_scene = preload("res://assets/computer/box/copy_material.tres")

@onready var desktop_orphanage : Node3D = preload("res://scenes/computer/box/desktop_orphanage.tscn").instantiate()

@onready var closed_copies : Node3D = $ClosedCopies


var orphanage

### Lifecycle ###

func _ready():
	corners = null
	pokemon = $Pokemon
	world_pickable = null
	minimized = null

	for box in get_children_boxes():
		box.take_priority.connect(_on_take_priority)
	
	get_tree().get_root().add_child.call_deferred(desktop_orphanage)
	orphanage = desktop_orphanage.get_node("SubViewport/Orphanage")

func _process(_delta):
	for poke in pokemon.get_children():
		poke.fix_pos(get_pos_corner(), get_neg_corner())



### Events ###

func _on_take_priority(child):
	boxes.move_child(child, 0)



### Helper ###

func in_bounds(_poke : DigitalPokemon):
	return true ## digital pokemon are always in the desktop

func adopt_to_specific(poke):
	poke.set_box(self)
	poke.reparent(pokemon)

	## Dont copy digital pokemon
	poke.copy = null

func power(on : bool):
	if on: 
		for orphan in orphanage.get_children():
			if orphan is DigitalPokemon:
				orphan.reparent(pokemon)

		for copy in closed_copies.get_children():
			copy.queue_free()
	else:
		for poke in get_children_pokemon():
			poke.reparent(orphanage)
			
		for box in get_children_boxes():
			if box.box_mode == BoxMode.MAXIMIZED:
				var copy = box.portal.duplicate()
				copy.set_script(null)
				copy.mesh = copy.mesh.duplicate()
				copy.mesh.flip_faces = false
				
				var mat = copy_material_scene.duplicate()
				mat.albedo_color = box.color
				copy.set_surface_override_material(0, mat)
				
				closed_copies.add_child(copy)
				
				copy.global_position = box.portal.global_position
			else:
				var copy = box.minimized.mesh.duplicate()
				copy.set_script(null)
				copy.mesh = copy.mesh.duplicate()
				copy.mesh.flip_faces = false
				
				var mat = copy_material_scene.duplicate()
				mat.albedo_color = box.color
				copy.set_surface_override_material(0, mat)
				
				closed_copies.add_child(copy)
				
				copy.global_position = box.minimized.mesh.global_position
	
	for box in get_children_boxes():
		box.power(on)
	
	# corners.power(on)

func get_parent_box():
	return false

func minimize():
	print("Error: Desktop cannot be minimized")

func delete():
	print("Error: Desktop cannot be deleted")

func get_pos_corner():
	return global_position + Vector3(3.5/2, 3.05, 3.5/2)

func get_neg_corner():
	return global_position + Vector3(-3.5/2, 0.05, -3.5/2)
