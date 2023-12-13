class_name PokeSpawner
extends StaticBody3D

@onready var pokemon_node = get_tree().get_root().get_node("Main/Pokemon")
@onready var pokescene = preload("res://scenes/pokemon.tscn")
@onready var audio : AudioStreamPlayer3D = $AudioStreamPlayer3D

### Lifecycle ###

func _ready():
	for child in get_children():
		if child is Keypad:
			child.spawn.connect(_spawn_pokemon)



### Events ###

# called when an id is entered into the keypad
func _spawn_pokemon(id):
	# play the teleporter audio
	audio.play()
	
	var pokemon = pokescene.instantiate()

	pokemon.id = id
	pokemon.position = Vector3(7.098, 0, -8.016)
	pokemon.rotation.y = PI

	pokemon_node.add_child(pokemon)
	pokemon.cry()
