# Corners

## Events

### _on_corner_move

When one corner moves, update all corners relative to that movement. Make sure it can't get too small. Make sure it can't go out of bounds

### _on_maximize

Updates the position of corners when box is maximized

## Helpers

### get_pos_corner

Gets the positive corner's position

### get_neg_corner

Gets the negative corner's position

### get_size

Gets the size of the box

### get_center

Gets the center of the box

### power

Enables or disables corners and enables/disables collision

### disable

Disables collision and makes corners invisible

### enable

Enables collision and makes corners visible

### get_pos_parent_bound

Gets the positive corner's position of the parent box

### get_neg_parent_bound

Gets the negative corner's position of the parent box

### check_bounds

Moves all corners within the bounds of the parent box