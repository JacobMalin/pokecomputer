# Box

## Lifecycle

### _process

Updates position and size of minimized_box, portal, collision, portal_reference_mesh, world_in_cube, digital pokemon

## Events

### _on_corner_move

Takes priority and updates children box bounds

### _on_take_priority

Move child to top of list and take priority for self

### _on_panel_press

If the panel press is for self, then perform relevant function. Else, propogate to children

### _on_world_move

Update digital pokemon position when world moves

### _on_world_accumulate

Update digital pokemon position when world accumulates

## Helper

### in_bounds

Return if digital pokemon is in this box

### adopt

Adopts digital pokemon to self, or child, if in bounds

### adopt_to_specific

Reparents and creates a copy of digital pokemon

### power

Changes this box to be on or off based on PC

### get_children_boxes

Get children boxes

### get_parent_box

Get parent box

### add

Add a new child box

### minimize

Minimize this box

### delete

Delete this box and reparent children

### box_modes

Change the mode of the box

### refresh_click

Called by double click animation after first click and resets click memory

### _on_minimized_box_area_entered

Maximize box if it is double clicked

### set_minimized_position

Set the position of the minimized box

### get_pos_corner

Get the positive corner position of the box

### get_neg_corner

Get the negative corner position of the box

### check_bounds

Moves the corners in bounds

### get_children_pokemon

Gets children pokemon

### get_children_pokemon_recursive

Recursively gets children pokemon