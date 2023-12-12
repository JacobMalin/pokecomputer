extends Area3D

@onready var skeleton : Skeleton3D = %RightController/RightHand/Hand_low_R/Armature/Skeleton3D
var indexTipIdx

# Called when the node enters the scene tree for the first time.
func _ready():
	indexTipIdx = skeleton.find_bone("Index_Tip_R")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = skeleton.get_bone_global_pose(indexTipIdx).origin
	position.z += 0.15
	position.y -= 0.04
	position.x += 0.035
	#print(skeleton.get_bone_global_pose(indexTipIdx).origin)
