extends Node3D

const SPEED = 40.0

@onready var mesh = $Slug
@onready var ray = $RayCast3D
@onready var metal_particles = $MetalParticles
@onready var blood_particles = $BloodParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	if ray.is_colliding():
		print("Bullet hit!")
		mesh.visible = false
		if ray.get_collider().is_in_group("deer"):
			blood_particles.emitting = true
		else:
			metal_particles.emitting = true
		ray.enabled = false
		await get_tree().create_timer(1.0).timeout
		queue_free()




func _on_timer_timeout() -> void:
	queue_free()
