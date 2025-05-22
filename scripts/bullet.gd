extends Node3D

const SPEED = 200

@onready var mesh = $RigidBody3D/Slug
@onready var hitbox = $RigidBody3D
@onready var metal_particles = $RigidBody3D/MetalParticles
@onready var blood_particles = $RigidBody3D/BloodParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	if hitbox.get_contact_count() == 1:
		var hitobjects = hitbox.get_colliding_bodies()
		if hitobjects[0].is_in_group("deer"):
			blood_particles.emitting = true
		else:
			metal_particles.emitting = true
		print(hitobjects[0])
		mesh.visible = false
		await get_tree().create_timer(1.0).timeout
		queue_free()
		

func _on_timer_timeout() -> void:
	print("MISS!")
	queue_free()

	
