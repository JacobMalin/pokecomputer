extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in $"..".get_children():
		if child.name == "Keypad":
			child.spawn.connect(spawner)

# called when an id is entered into the keypad
func spawner(id):
	var pokescene = preload("res://scenes/pokemon.tscn")
	var pokemon = pokescene.instantiate()
	pokemon.id = id
	pokemon.position = Vector3(7.098, 0, -8.016)
	pokemon.rotation.y = PI
	$"../Pokemon".add_child(pokemon)
