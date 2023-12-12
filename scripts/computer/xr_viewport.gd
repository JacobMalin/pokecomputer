extends SubViewport

var xr_interface : XRInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface('OpenXR')

	size = xr_interface.get_render_target_size()
