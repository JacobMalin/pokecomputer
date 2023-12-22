# Pokeball

## Lifecycle

#### _process

Controlls and animates pokeball rise and drop

#### _integrate_forces

Animates pokeball rise

## Super Overrides

#### request_highlight

Add rumble call when highlighted by controller

## Events

#### _on_pokeball_hit_something

When pokeball hits surface and is primed, starts pokeball capture/release animation

#### _on_pokeball_dropped

When pokeball is dropped by a controller, prime the pokeball for capture/release

#### _on_pokeball_picked_up

When pokeball is picked up by controller, unprime the pokeball

#### _on_digi_snap_has_dropped

When digital pokemon is taken out of holster reparent digital pokemon from pokeball to pc

#### _on_digi_snap_has_picked_up

When digital pokemon is placed into holster reparent digital pokemon from pc to pokeball

## Helper

#### enter_computer

When pokeball enters computer, make invisible

#### exit_computer

When pokeball exits computer, make semi-transparent

#### enter_holster

When pokeball enters holster, make semi-transparent and unprime pokeball

#### exit_holster

When pokeball exits holster, make opaque

#### display

Update pokeball mesh transparency and appropriately disable/enable collisions/visibility

#### rumble

Rumble controller

### Rise Phase

#### scan

If pokeball is empty, choose closest pokemon to capture and mark pokemon as precaptured

#### is_closer

Return if poke is closer than _min

### Hold Phase

#### capture_and_release

If empty, start capture, else start release

#### capture

Captures the pokemon

#### release

Deletes the digital pokemon and reinstantiates and relases the pokemon

#### release_position

Returns a position on the ground 1 meter away from ball in the direction of the player

### Drop Phase

#### drop_start

At end of capture, create digital pokemon and delete pokemon