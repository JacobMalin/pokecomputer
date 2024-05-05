# PokéComputer: World-In-Cube

By: Jacob Malin (malin146), Ben Larson (lars6866)

## Description

This is a prototype of a virtual 3D Folder System that uses a specific technique that we are calling World-In-Cube to allow each folder to be a sub-world that the user can view and interact with. To give an example use case for this prototype, the folder system can store Pokémon that can be placed in the computer after they have been digitized into a Pokéball. This project was built in Godot for the Meta Quest 2.

## The Pokéballs

Taking advantage of virtual reality user input design, all user input is either pushing buttons or throwing objects. In the case of the pokéballs, throwing a pokéball will activate it and attempt to catch the closest pokémon. Throwing the pokéball again will release the pokémon to walk around.

https://github.com/JacobMalin/pokecomputer/assets/34765120/dc4df893-3222-4c32-88e6-2a4968fc8930

https://github.com/JacobMalin/pokecomputer/assets/34765120/64732fa7-320d-44e3-a26f-880f50e77636

## The pokéholster and the mirror

The pokéballs are stored in the pokéholster attached to the player's waist. Looking down at the pokéholster will move the pokéballs to the front for ease of access. As well, the holster is equipped with haptic feedback to allow the user to grab pokéballs while not looking down. The mirror is built with the same portal technology that enables the pokéboxes to operate.

https://github.com/JacobMalin/pokecomputer/assets/34765120/698ffd86-6faf-49a1-9036-249a5940c860

## The Pokéspawner

The pokéspawner allows the user to bring in more pokémon to capture and store in the PokéComputer.

https://github.com/JacobMalin/pokecomputer/assets/34765120/41c64dcf-2e3b-4c9f-b827-a40cfbbec40c

https://github.com/JacobMalin/pokecomputer/assets/34765120/7edee92f-b1e1-454a-b3c0-fa0110194d8b

https://github.com/JacobMalin/pokecomputer/assets/34765120/588fc0e4-fb5f-40a1-8ed0-30c97e3dd3bf

## The PokéComputer

Taking after the PokéComputer from the games, the PokéComputer allows the user to store and later retrieve pokémon. The PokéComputer user interface can be opened and closed by tapping on the screen of the computer.

https://github.com/JacobMalin/pokecomputer/assets/34765120/c840918b-21ab-4531-a3f1-f97e7bf7dd1e

In the opened state, users can grab pokémon from their digital pokéholster, which will remove the pokémon from the pokéball. The pokémon can be then placed within the bounds of the computer for safe storage.

https://github.com/JacobMalin/pokecomputer/assets/34765120/7a0077ef-5cb0-4aa3-b8ab-54ae84425283

Users can arrange their pokémon however they would like, placing them within the desktop space or within boxes. 

https://github.com/JacobMalin/pokecomputer/assets/34765120/8e9bb208-dc3e-4255-b29a-33443be55dbb

The World-In-Cube illusion is what allows the boxes to appear so dynamic. Within each box exists a sub-world in which pokémon can be stored. The boxes are simply 'windows' into the sub-world that allow the user to view their contents and interact with the contents within the bounds of the window. The illusion of the world-in-cube becomes complete when stepping inside of the box, at which point only the light-gray tinted window indicates that you are not present within the sub-world.

https://github.com/JacobMalin/pokecomputer/assets/34765120/216139cb-01d7-4caf-be9f-6fc7f439794a

The boxes may be resized to view more or less of the world within the box. Notably, this means that from certain angles, the pokémon within the box may not be visible.

https://github.com/JacobMalin/pokecomputer/assets/34765120/916956ba-f291-4cbe-a8a4-4d7cf6dec04c

The pokéwatch allows for interaction with the PokéComputer. The pokéwatch is only accessible when the user's hands are within the desktop area, and appears when the user rotates their palm towards them. Within the desktop new boxes can be created with the red button. If the user's hand is within a box, the white button can be used to delete the box and the center button may be used to minimize the box. A minimized box may be restored by double-tapping the box.

https://github.com/JacobMalin/pokecomputer/assets/34765120/294f3f96-d37c-44cc-a292-c20086026466

Boxes may, of course, be nested by pushing the red button to spawn a new box while the user's hand is within a box.

https://github.com/JacobMalin/pokecomputer/assets/34765120/8dbab98d-3b37-469e-9187-ceaefa1d868e

Finally, the contents of a box may be moved around by grabbing the air within a box and dragging it around.

https://github.com/JacobMalin/pokecomputer/assets/34765120/0e145e9c-5a0f-49a2-80d1-a09aa61304fe

## Documentation

- [Computer](documentation/computer/computer_doc.md)
- [Hands](documentation/hands/hands_doc.md)
- [Holster](documentation/holster/holster_doc.md)
- [Pokéball](documentation/pokeball/pokeball_doc.md)
- [Pokémon](documentation/pokemon/pokemon_doc.md)
- [Pokéspawner](documentation/pokespawner/pokespawner_doc.md)

## Third Party Assets

- Models
  - Pokémon
    - [Pokémon models](https://gitlab.com/cable-mc/cobblemon-assets/-/tree/master/blockbench/pokemon/gen1) from Cobblemon public asset database
    - [Substitute Doll Model](https://www.models-resource.com/3ds/pokemonomegarubyalphasapphire/model/12155/) by Hallow
  - Pokéball
    - [Pokéball](https://www.turbosquid.com/3d-models/pok%C3%A9-ball-c4d-free/717151) by WafflesAu
    - [Masterball](https://www.cgtrader.com/free-3d-models/sports/toy/pokeball-collection) by Atlas-Labs
  - Computer
    - [Pokémon Computer Model + Textures](https://www.models-resource.com/3ds/pokemonxy/model/13867/) by Hallow
  - Pokewatch based off of
    - [Pokemon Token](https://cults3d.com/en/3d-model/game/pokemon-pokeball-token)
  - Misc
    - [Lab Machine](https://sketchfab.com/3d-models/laboratory-wall-pc-aa5e7257a65b4b63bb958d499336a885) by Christian Quintero Vázquez
    - [Cut Tree](https://www.turbosquid.com/3d-models/3d-assets-tree-grass-rocks-1498368) by Just Create
    - [Bookshelf](https://sketchfab.com/3d-models/bookshelf-01-fetizworks-27e1808f4cdf46ddb8deb978029da366) by Fetiz.works
- Sounds
  - Pokémon
    - [Pokémon Cries](https://play.pokemonshowdown.com/audio/cries/) from Pokémon Showdown database
    - [Meowth Cry](https://www.youtube.com/watch?v=wDgOlC7rHrg&ab_channel=Dwain) by Dwain
    - [Substitute Sound Effect](https://downloads.khinsider.com/game-soundtracks/album/pokemon-sfx-gen-3-attack-moves-rse-fr-lg/Substitute.mp3) from downloads.khinsider.com
  - Pokéball
    - [Pokéball Opening Sound Effect](https://www.myinstants.com/en/instant/pokeball-open/) by nauth
    - [Pokéball Closing Sound Effect](https://www.myinstants.com/en/instant/pokeball-return/) by nauth
  - Computer
    - [Pokémon Computer Boot-up Sound](https://www.youtube.com/watch?v=fwEzOeeZxUE&ab_channel=Matteo) by Matteo
    - [PC Close](https://reliccastle.com/resources/220/)
    - [Button Press Audio from Gen 4 Sound Effects Pack](https://reliccastle.com/resources/220/) by Deo
  - Misc
    - [Oak Pokémon Lab Theme](https://www.youtube.com/watch?v=9AtffDvUbUU&ab_channel=TheCoffingsExtended) by TheCoffingsExtended
    - [Pokespawner Sound Effect](https://downloads.khinsider.com/game-soundtracks/album/pokemon-sfx-gen-3-attack-moves-rse-fr-lg/Teleport.mp3) from downloads.khinsider.com
- Code References
  - Portal based off of
    - [How to Make Portals in Godot 4 in Just 5 Minutes](https://www.youtube.com/watch?v=oqDdIg3BRlg)
    - [Coding Adventure: Portals](https://www.youtube.com/watch?v=cWpFZbjtSQg)
  - Rotation code based off of
    - [Actual rotation](https://www.reddit.com/r/godot/comments/coy5e8/pathfinding_how_to_rotate_my_unit_towards_the/)
    - [Supress errors](https://github.com/godotengine/godot/issues/79146)
