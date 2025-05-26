extends CharacterBody3D


const SPEED = 5.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

#Bobbing variables
const BOB_FREQ = 1.5
const BOB_AMP = 0.04
var t_bob = 0.0

var gravity = 9.8
var gun_equipped = false

# Bullets
var bullet = load("res://prefabs/gun/bullet.tscn")
var instance
var bullet_count = 100

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var groundray = $GroundRay
@onready var interactray = $Head/InteractRay
@onready var gun_barrel = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/Henry410_Test/RayCast3D
@onready var gun_smoke = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/Henry410_Test/SmokeParticles
@onready var gun_flash = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/Henry410_Test/MuzzleFlash
@onready var gun_viewmodel = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera
@onready var gun_sound = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/Henry410_Test/AudioStreamPlayer3D
@onready var anim_play = $AnimationPlayer
@onready var char_model = $Humanoid
@onready var feet_sfx = $feet_sfx
@onready var feet_sfx_lib = ["res://assets/audio/sfx/player/A_Footsteps_Walk-001.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-002.ogg",
"res://assets/audio/sfx/player/A_Footsteps_Walk-003.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-004.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-005.ogg",
"res://assets/audio/sfx/player/A_Footsteps_Walk-006.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-007.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-008.ogg"]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	gun_viewmodel.visible = false
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		interactray.rotate_x(-event.relative.y * SENSITIVITY)
		interactray.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		char_model.rotate_y(-event.relative.x * SENSITIVITY)


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
			anim_play.play("walk")
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		anim_play.stop()
		anim_play.play("Default")
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0) # Adds inertia to fall
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		
	if velocity == Vector3(0,0,0):
		anim_play.stop()
		anim_play.play("Default")
		

		
	# Head bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	$Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera.global_transform = camera.global_transform
	
	# Shooting
	if Input.is_action_just_pressed("shoot") and bullet_count >= 0 and gun_equipped:
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		gun_smoke.emitting = true
		gun_flash.emitting = true
		gun_smoke.restart()
		gun_flash.restart()
		gun_sound.play()
		get_tree().root.add_child(instance)
		bullet_count -= 1
		
	# Crouching
	# if Input.is_action_pressed("crouch"):
		
		

	move_and_slide()
	
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func gun_taken():
	gun_viewmodel.visible = true
	gun_equipped = true
	
func _make_footstep():
	if groundray.is_colliding():
		if groundray.get_collider().is_in_group("snow"):
			print("Snow Fella")
			var random_int = randi_range(0,7)
			feet_sfx.stream = load(feet_sfx_lib[random_int])
			feet_sfx.play()
		elif groundray.get_collider().is_in_group("wood"):
			print("Wood Fella")
		else:
			feet_sfx.stop()
	
