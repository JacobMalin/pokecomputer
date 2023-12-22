# Pokewatch

## Lifecycle

### _process

Updates the visibility of the panels

## Events

### _on_button_pressed

Changes the visibility of the watch when a controller button is pressed

### _on_button_released
Changes the visibility of the watch when a controller button is released

### _on_panel_pressed
Checks the position of the panel when pressed, and sends a signal to the box the watch is in

## Signals

### _on_area_entered

Updates mode of the pokewatch based on areas the user enters

### _on_area_exited

Updates mode of the pokewatch based on areas the user exits

## Helper

### pokewatch

Makes the panels visible/invisible based on the mode

### get_current_area

Gets the box the watch is currently in

### check_area

Recursively checks which box the watch is in