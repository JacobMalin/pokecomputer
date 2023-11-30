extends Area3D

@onready var skeleton : Skeleton3D = %LeftController/LeftHand/Hand_low_L/Armature/Skeleton3D
var indexTipIdx

# Called when the node enters the scene tree for the first time.
func _ready():
	indexTipIdx = skeleton.find_bone("Index_Tip_L")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = skeleton.get_bone_global_pose(indexTipIdx).origin
	position.z += 0.15
	position.y -= 0.05
	position.x -= 0.037
	#print(skeleton.get_bone_global_pose(indexTipIdx).origin)
