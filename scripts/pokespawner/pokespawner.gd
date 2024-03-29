class_name PokeSpawner
extends StaticBody3D

@onready var pokemon_node = get_tree().get_root().get_node("Main/Pokemon")
@onready var pokescene = preload("res://scenes/pokemon/pokemon.tscn")
@onready var audio : AudioStreamPlayer3D = $AudioStreamPlayer3D

### Lifecycle ###

func _ready():
	for child in get_children():
		if child is Keypad:
			child.spawn.connect(_spawn_pokemon)



### Events ###

# Spawn a new pokemon into the scene
func _spawn_pokemon(id):
	# play the teleporter audio
	audio.play()
	
	var pokemon = pokescene.instantiate()

	pokemon.id = id
	
	# adjust newly spawned pokemon to be in the right place
	pokemon.position = Vector3(7.098, 0, -8.016)
	pokemon.rotation.y = PI

	pokemon_node.add_child(pokemon)
	pokemon.cry()
