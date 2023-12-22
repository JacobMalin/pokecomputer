# Corner

## Lifecycle

### _process

Locks rotation and signals corner position to corners

### _integrate_forces

Updates global position

## Super Overrides

### request_highlight

Change request_highlight so that highlight is kept when held

## Events

### _on_corner_move

Update corner depending on other corner movement

## Helpers

### fix_pos

Fix the position of the corner

### fix_bounds

Moves corner into bounds of parent box

### power

Enables or disables corner and enables/disables collision

### disable

Disables collision

### enable

Enables collision