extends CharacterBody3D


const SPEED = 5.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

var HEALTH = 100


#Bobbing variables
const BOB_FREQ = 1.5
const BOB_AMP = 0.04
var t_bob = 0.0

var gravity = 9.8
var gun_equipped = false
var crouching = false

# Bullets
var bullet = load("res://prefabs/gun/bullet.tscn")
var instance
var bullet_count = 1
var bullet_reserve = 12
var reload_finished = true

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var groundray = $GroundRay
@onready var interactray = $Head/InteractRay
@onready var gun_barrel = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/HuntingViewmodelNLA/RayCast3D
@onready var gun_smoke = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/HuntingViewmodelNLA/SmokeParticles
@onready var gun_flash = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/HuntingViewmodelNLA/MuzzleFlash
@onready var gun_viewmodel = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera
@onready var gun_sfx = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/HuntingViewmodelNLA/AudioStreamPlayer3D
@onready var gun_sfx_lib = ["res://assets/audio/sfx/gun/A_Shotgun.ogg","res://assets/audio/sfx/gun/A_Shotgun_Grab.ogg","res://assets/audio/sfx/gun/A_Shotgun_Reload-001.ogg",
"res://assets/audio/sfx/gun/A_Shotgun_Reload-002.ogg"]
@onready var gun_anim_tree = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/HuntingViewmodelNLA/AnimationTree
@onready var anim_play = $AnimationPlayer
@onready var char_model = $Humanoid
@onready var feet_sfx = $feet_sfx
@onready var feet_sfx_lib = ["res://assets/audio/sfx/player/A_Footsteps_Walk-001.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-002.ogg",
"res://assets/audio/sfx/player/A_Footsteps_Walk-003.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-004.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-005.ogg",
"res://assets/audio/sfx/player/A_Footsteps_Walk-006.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-007.ogg","res://assets/audio/sfx/player/A_Footsteps_Walk-008.ogg",
"res://assets/audio/sfx/player/A_Footstep_Wood-001.ogg","res://assets/audio/sfx/player/A_Footstep_Wood-002.ogg","res://assets/audio/sfx/player/A_Footstep_Wood-003.ogg",
"res://assets/audio/sfx/player/A_Footstep_Wood-004.ogg","res://assets/audio/sfx/player/A_Footstep_Wood-005.ogg","res://assets/audio/sfx/player/A_Footstep_Wood-006.ogg",
"res://assets/audio/sfx/player/A_Footstep_Wood-007.ogg","res://assets/audio/sfx/player/A_Footstep_Wood-008.ogg"]
@onready var death_sfx_lib = ["res://assets/audio/sfx/player/A_Player_Dying-001.ogg","res://assets/audio/sfx/player/A_Player_Dying-002.ogg",
"res://assets/audio/sfx/player/A_Player_Dying-003.ogg","res://assets/audio/sfx/player/A_Player_Dying-004.ogg","res://assets/audio/sfx/player/A_Player_Dying-005.ogg"]

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
	print(gun_anim_tree.get("parameters/playback").get_current_node())
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
			gun_anim_tree.set("parameters/conditions/idle", false)
			gun_anim_tree.set("parameters/conditions/walk", true)
		else:
			gun_anim_tree.set("parameters/conditions/walk", false)
			gun_anim_tree.set("parameters/conditions/idle", true)
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		gun_anim_tree.set("parameters/conditions/walk", false)
		gun_anim_tree.set("parameters/conditions/idle", true)
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
	if Input.is_action_just_pressed("shoot") and bullet_count > 0 and reload_finished and gun_equipped:
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		gun_smoke.emitting = true
		gun_flash.emitting = true
		gun_smoke.restart()
		gun_flash.restart()
		gun_sfx.stream = load(gun_sfx_lib[0])
		gun_sfx.play()
		get_tree().root.add_child(instance)
		bullet_count -= 1
		gun_anim_tree.set("parameters/conditions/shoot", true)
		
	if Input.is_action_just_pressed("reload") and bullet_count == 0 and bullet_reserve > 0 and gun_equipped:
		bullet_count += 1
		bullet_reserve -= 1
		gun_anim_tree.set("parameters/conditions/reload", true)
		reload_finished = false
		
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
	gun_sfx.stream = load(gun_sfx_lib[1])
	gun_sfx.play()
	
func _make_footstep():
	if groundray.is_colliding():
		if groundray.get_collider().is_in_group("snow"):
			print("Snow Fella")
			var random_int = randi_range(0,7)
			feet_sfx.stream = load(feet_sfx_lib[random_int])
			feet_sfx.play()
		elif groundray.get_collider().is_in_group("wood"):
			print("Wood Fella")
			var random_int = randi_range(8,15)
			feet_sfx.stream = load(feet_sfx_lib[random_int])
			feet_sfx.play()
		else:
			feet_sfx.stop()
			
func hit(damage, knockback_origin):
	print("HIT!")
	HEALTH -= damage
	velocity.y += 3
	move_and_slide()
	velocity += (global_transform.origin - knockback_origin).normalized() * 10
	if HEALTH <= 0:
		var random_int = randi_range(0,4)
		feet_sfx.stream = load(death_sfx_lib[random_int])
		feet_sfx.play()
		print("player dead")
	
func reload():
	reload_finished = true
	gun_anim_tree.set("parameters/conditions/reload", false)
	gun_anim_tree.set("parameters/conditions/idle", !crouching)
	gun_anim_tree.set("parameters/conditions/crouch", crouching)
	
	
