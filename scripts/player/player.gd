extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

#Bobbing variables
const BOB_FREQ = 1.5
const BOB_AMP = 0.04
var t_bob = 0.0

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interactray = $Head/InteractRay

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		interactray.rotate_x(-event.relative.y * SENSITIVITY)
		interactray.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0) # Adds inertia to fall
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		
	# Head bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# Shooting
	#if Input.is_action_just_pressed("shoot"):
		

	move_and_slide()
	
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_static_body_3d_2_interacted(body: Variant) -> void:
	pass # Replace with function body.
