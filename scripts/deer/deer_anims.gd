extends Node3D

var hoove_sfx_lib = ["res://assets/audio/sfx/player/A_Footsteps_Walk-001.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-002.ogg",
"res://assets/audio/sfx/player/A_Footsteps_Walk-003.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-004.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-005.ogg",
"res://assets/audio/sfx/player/A_Footsteps_Walk-006.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-007.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-008.ogg"]

@onready var hoove_sfx = $HooveSfx
var can_audio: bool = true


func _ready():
	get_parent().deer_dead.connect(disable_footsteps_audio)
	$"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Root/pickup".deer_get.connect(disable_skeleton)

func _hoovesteps():
	if can_audio:
		hoove_sfx.stream = load(hoove_sfx_lib[(randi() % 8)])
		hoove_sfx.play()

func disable_footsteps_audio():
	can_audio = false

func enable_footsteps_audio():
	can_audio = true

func disable_skeleton():
	for bone: PhysicalBone3D in $Armature/Skeleton3D/PhysicalBoneSimulator3D.get_children():
		pass
