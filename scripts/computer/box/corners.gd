class_name Corners
extends Node3D

signal corner_move
signal request_fix_pos

enum Id {X = 1, Y = 2, Z = 4}

@onready var MIN_SIZE = get_parent().MIN_SIZE
@onready var PADDING = get_parent().PADDING

@onready var corners = get_children()
@onready var pos_corner = $"Corner+++"
@onready var neg_corner = $"Corner---"


### Lifecycle ###

func _ready():
	for corner in corners:
		corner.corner_move.connect(_on_corner_move)



### Events ###

# Recieved from all children then broadcasted to all children
func _on_corner_move(id, _position):
	
	# Calc pos and neg corner
	var pos = get_pos_corner()
	var neg = get_neg_corner()

	if id & Id.X: pos.x = _position.x
	else: neg.x = _position.x

	if id & Id.Y: pos.y = _position.y
	else: neg.y = _position.y

	if id & Id.Z: pos.z = _position.z
	else: neg.z = _position.z


	# Check and fix too small
	var size = pos - neg

	if size.x < MIN_SIZE:
		if id & Id.X: pos.x = neg.x + MIN_SIZE
		else: neg.x = pos.x - MIN_SIZE

	if size.y < MIN_SIZE:
		if id & Id.Y: pos.y = neg.y + MIN_SIZE
		else: neg.y = pos.y - MIN_SIZE

	if size.z < MIN_SIZE:
		if id & Id.Z: pos.z = neg.z + MIN_SIZE
		else: neg.z = pos.z - MIN_SIZE

	# Clamp to parent box bounds
	pos = pos.clamp(get_neg_parent_bound() + Vector3.ONE * PADDING,
					get_pos_parent_bound() - Vector3.ONE * PADDING)
	neg = neg.clamp(get_neg_parent_bound() + Vector3.ONE * PADDING,
					get_pos_parent_bound() - Vector3.ONE * PADDING)

	# Update corners
	for corner in corners:
		corner.fix_pos(pos, neg)

	# Signal up
	corner_move.emit()

func _on_maximize(new_center):
	var pos = get_pos_corner()
	var neg = get_neg_corner()

	var old_center = get_center()

	var old_to_new = (new_center - old_center) / 2
	pos += old_to_new
	neg += old_to_new

	# Update corners
	for corner in corners:
		corner.fix_pos(pos, neg)

### Helpers ###

func get_pos_corner():
	return pos_corner.new_position

func get_neg_corner():
	return neg_corner.new_position

func get_size():
	return get_pos_corner() - get_neg_corner()

func get_center():
	return (get_pos_corner() + get_neg_corner()) / 2

func power(on : bool):
	for corner in corners:
		corner.power(on)

func disable():
	hide()

	for corner in corners:
		corner.disable()

func enable():
	show()

	for corner in corners:
		corner.enable()

func get_pos_parent_bound():
	return get_parent().get_parent_box().get_pos_corner()

func get_neg_parent_bound():
	return get_parent().get_parent_box().get_neg_corner()

func check_bounds():
	var pos = get_pos_corner()
	var neg = get_neg_corner()

	# Clamp to parent box bounds
	pos = pos.clamp(get_neg_parent_bound() + Vector3.ONE * PADDING,
					get_pos_parent_bound() - Vector3.ONE * PADDING)
	neg = neg.clamp(get_neg_parent_bound() + Vector3.ONE * PADDING,
					get_pos_parent_bound() - Vector3.ONE * PADDING)

	# Update corners
	for corner in corners:
		corner.fix_pos(pos, neg)