class_name Computer
extends Node3D

### Helper ###

# Add a digital pokemon to the computer
func adopt(poke : DigitalPokemon):
	poke.reparent(self)
