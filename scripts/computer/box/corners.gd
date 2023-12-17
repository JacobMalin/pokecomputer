class_name Corners
extends Node3D

signal corner_move(pos, neg) # Global position
signal request_fix_pos

@onready var corners = get_children()
@onready var pos_corner = $"Corner+++"
@onready var neg_corner = $"Corner---"


### Lifecycle ###

func _ready():
	for corner in corners:
		corner.corner_move.connect(_on_corner_move)
		corner.request_fix_pos.connect(_on_request_fix_pos)



### Events ###

# Recieved from all children then broadcasted to all children
func _on_corner_move(id, pos):
	for corner in corners:
		corner._on_corner_move(id, pos)
	
	corner_move.emit(pos_corner.global_position, neg_corner.global_position)

func _on_request_fix_pos():
	request_fix_pos.emit()

### Helpers ###

func fix_pos(pos, neg):
	for corner in corners:
		corner.fix_pos(pos, neg)

func get_pos_corner():
	return pos_corner.global_position

func get_neg_corner():
	return neg_corner.global_position

func power(on : bool):
	for corner in corners:
		corner.power(on)
