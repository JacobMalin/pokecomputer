class_name Desktop
extends Box

### Lifecycle ###

func _ready():
	corners = null
	pokemon = $Pokemon

	save_pos = global_position + Vector3(3.5/2, 3, 3.5/2)
	save_neg = global_position + Vector3(-3.5/2, 0, -3.5/2)

	for box in boxes.get_children():
		box.check_bounds.connect(_on_check_bounds)
		box.take_priority.connect(_on_take_priority)



### Events ###

func _on_corner_move(_pos:Vector3, _neg:Vector3):
	pass


func fix_pos(_pos, _neg):
	pass

func _on_take_priority(child):
	boxes.move_child(child, 0)

	# Desktop already has priority
	# take_priority.emit(self)



### Helper ###

func in_bounds(_poke : DigitalPokemon):
	return true ## digital pokemon are always in the desktop

func adopt(poke : DigitalPokemon):
	if not in_bounds(poke): return false

	for box in boxes.get_children():
		var ret = box.adopt(poke)
		if ret: return true

	poke.reparent(pokemon)

	return true

func power(on : bool):
	for box in boxes.get_children():
		box.power(on)
	
	# corners.power(on)
