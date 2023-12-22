# Pokemon

## Lifecycle

#### _physics_process

Does pokemon navigation

#### _process

Animates pokemon movement duing capture and release phases

## Events

#### _on_navigation_agent_3d_navigation_finished

When navigation is finished, assign new target

## Helper

#### actor_setup

Once nav map is set up, start pokemon idle or walk

#### set_movement_target

Set new movement target

#### clear_movement_target

Clear movement target

#### cry

Play cry sound and animation

#### is_free

Checks if pokemon is not captured

#### anim_in_list

Check if animation exists

#### safe_anim_play

Safely play an animation, or if it doesn't exist, safely play a backup

#### safe_anim_queue

Safely queue an animation, or if it doesn't exist, safely queue a backup

### Pokemon move states

#### walk

Set the pokemon to walk, or if no animation exists, idle

#### idle

Set the pokemon to idle

### Pokemon capture states

#### pre_capture

Marks pokemon as not available to capture

#### capture

Capture the pokemon

#### end_capture

Marks state to contain after capture animation

#### release

Releases the pokemon

#### end_release

Marks state to free after release animation and sets poke to walk