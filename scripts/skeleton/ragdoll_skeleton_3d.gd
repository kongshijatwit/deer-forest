extends Skeleton3D

@onready var phys_skel = $PhysicalBoneSimulator3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phys_skel.physical_bones_start_simulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
