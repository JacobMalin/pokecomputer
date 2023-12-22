# Digital Pokemon

## Lifecycle

### _process

If in a box that is not the desktop, update shader parameters so that clipping works

## Super Overrides

### let_go

Add a function call that is called when dropped by controller

### pick_up

Add a function call that is called when picked up by controller

### request_highlight

Add rumble call when highlighted by controller

## Events

### _on_exit_box

Makes self intangible when not intersecting box

### _on_enter_box

Makes self tangible when intersecting box

## Helper

### anim_in_list

Check if animation exists

### safe_poke_anim_play

Safely play an animation, or if it doesn't exist, safely play a backup

### cry

Play cry sound and animation

### idle

Set the pokemon to idle

### _on_let_go_by_controller

Disable snap points, play grow animation, and adopt to pc when dropped by controller

### _on_picked_up_by_ball

Reactivate snap points, play shrink animation, and frees copy when picked up by ball

### _on_picked_up_by_controller

Frees copy and parents to desktop when picked up by controller

### disable_snap

Disables hand snap points

### activate_snap

Enables hand snap points

### grow

Plays grow animation

### shrink

Plays shrink animation

### set_box

Changes which box the digital pokemon believes it is in and updates relevant shader and  tangibility

### tangible

Makes digital pokemon tangible or intangible

### apply_shader

Recursively replaces material with shader materials

### rumble

Rumbles the controller

### fix_pos

Bounds digital pokemon between pos and neg

### update_pos_to_copy

Moves digital pokemon to it's copy's position