extends Area3D

enum LorR {LEFT, RIGHT}
@export var hand : LorR = LorR.LEFT

const POS_ADJUST = {
	LorR.LEFT: Vector3(-0.037, -0.04, 0.15),
	LorR.RIGHT: Vector3(0.035, -0.04, 0.15),
}

var skeleton
var indexTipIdx

### Lifecycle ###

func _ready():
	if hand == LorR.LEFT:
		skeleton = %LeftController/LeftHand/Hand_low_L/Armature/Skeleton3D
		indexTipIdx = skeleton.find_bone("Index_Tip_L")
	else:
		skeleton = %RightController/RightHand/Hand_low_R/Armature/Skeleton3D
		indexTipIdx = skeleton.find_bone("Index_Tip_R")

# Sets position of collision to align with index tip bone
func _process(_delta):
	# adjust index finger collision positions to actually be on the index finger
	position = skeleton.get_bone_global_pose(indexTipIdx).origin
	position += POS_ADJUST[hand]



### Helper ###

# Forwards rumble call to parent controller
func rumble():
	get_parent().rumble()
