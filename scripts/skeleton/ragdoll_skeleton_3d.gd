extends Skeleton3D

@onready var phys_skel = $PhysicalBoneSimulator3D

func _ready() -> void:
	phys_skel.physical_bones_start_simulation()
