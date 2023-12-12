class_name RumbleController
extends XRController3D

func rumble():
	trigger_haptic_pulse("haptic", 0, 0.1, 0.1, 0)

func enter_rumble():
	trigger_haptic_pulse("haptic", 0, 0.15, 0.1, 0)

func exit_rumble():
	trigger_haptic_pulse("haptic", 0, 0.01, 0.05, 0)

func full_rumble():
	trigger_haptic_pulse("haptic", 0, 0.1, 0.15, 0)

func empty_rumble():
	trigger_haptic_pulse("haptic", 0, 0.15, 0.07, 0)