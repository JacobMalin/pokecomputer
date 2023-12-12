class_name Desktop
extends Box



### Lifecycle ###

func _ready():
	corners = null

	save_pos = cube.global_position + Vector3(3.5/2, 1.5, 3.5/2)
	save_neg = cube.global_position + Vector3(-3.5/2, -1.5, -3.5/2)

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
