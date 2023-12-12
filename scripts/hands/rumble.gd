extends XRController3D

func rumble():
	trigger_haptic_pulse("haptic", 0, 0.1, 0.1, 0)