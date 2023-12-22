# World Pickable

## Lifecycle

### _process

Locks the rotation, bounds it to the parent box, and signals the parent box of the position when held by a controller

### _integrate_forces

Updates global position of the minimized box

## Events

### _on_dropped

Signals the parent box of the accumulated position when dropped by a controller

## Helpers

### fix_pos

Updates the position and size of collision to match collision of the box

### disable

Disables collision

### enable

Enables collision