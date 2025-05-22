extends RigidBody3D

func _physics_process(delta: float) -> void:
    move_and_collide(Vector3(0, 0, 35) * delta)