class_name RumbleController
extends XRController3D

@export var do_rumble = true

### Helper ###

# Normal rumble
func rumble():
	if do_rumble: trigger_haptic_pulse("haptic", 0, 0.1, 0.1, 0)

# Rumble when object hovers over slot
func enter_rumble():
	if do_rumble: trigger_haptic_pulse("haptic", 0, 0.15, 0.1, 0)

# Rumble when object stops hovering over slot
func exit_rumble():
	if do_rumble: trigger_haptic_pulse("haptic", 0, 0.01, 0.05, 0)

# Rumble when highlighting a full pokeball
func full_rumble():
	if do_rumble: trigger_haptic_pulse("haptic", 0, 0.1, 0.15, 0)

# Rumble when highlighting an empty pokeball
func empty_rumble():
	if do_rumble: trigger_haptic_pulse("haptic", 0, 0.15, 0.07, 0)