# Holster Slot

## Super Overrides

### _ready

Overwrite super._ready to allow for cube shaped collision

### drop_object

Added line to remove object from holster when dropped

### _on_snap_zone_body_entered

Adds rumble to hover over snap point with pokeball

### _on_snap_zone_body_exited

Adds rumble to exit hover over snap point with pokeball

## Signals

### _on_area_entered

Makes holster digital when enters computer

### _on_area_exited

Makes holster default when enters computer

### _on_has_picked_up

When picks up a pokeball, inform it that it is in the holster

## Helper

### holster

Change visibility based on holster state

### enter_rumble

Rumble when pokeball hovers over slot

### exit_rumble

Rumble when pokeball exits hover over slot