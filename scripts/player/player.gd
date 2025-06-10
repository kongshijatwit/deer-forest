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
var actions_disabled = false

# Bullets
var bullet = load("res://prefabs/gun/bullet.tscn")
var instance
var bullet_count = 1
var bullet_reserve = 24
var reloading = false
var reload_finished = true
var shooting = false
var shot_finished = true

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
@onready var anim_tree = $AnimationTree
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
	%dialog_blocker.talking.connect(disable_actions)
	%dialog_blocker.done_talking.connect(enable_actions)
	%game_manager/fade.transitioned.connect(enable_actions)
	%game_manager.reset.connect(reset_gun)

	
func _unhandled_input(event):
	if event is InputEventMouseMotion and !actions_disabled:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		interactray.rotate_x(-event.relative.y * SENSITIVITY)
		interactray.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		char_model.rotate_y(-event.relative.x * SENSITIVITY)


func _physics_process(delta):
	anim_tree.set("parameters/conditions/death", HEALTH == 0 and !crouching)
	anim_tree.set("parameters/conditions/crouch_death", HEALTH == 0 and crouching)
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
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0) # Adds inertia to fall
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		
		
	anim_tree.set("parameters/conditions/walk", !(velocity.x == 0 and velocity.z == 0) and reload_finished and !crouching)
	anim_tree.set("parameters/conditions/crouch_walk", !(velocity.x == 0 and velocity.z == 0) and reload_finished and crouching)
	anim_tree.set("parameters/conditions/idle", velocity.x == 0 and velocity.z == 0 and reload_finished and !crouching)
	anim_tree.set("parameters/conditions/crouch_idle", velocity.x == 0 and velocity.z == 0 and reload_finished and !crouching)
	
	gun_anim_tree.set("parameters/conditions/idle", velocity.x == 0 and velocity.z == 0 and reload_finished and !crouching)
	gun_anim_tree.set("parameters/conditions/walk",  !(velocity.x == 0 and velocity.z == 0) and reload_finished and !crouching)
	gun_anim_tree.set("parameters/conditions/shoot", shooting)
	gun_anim_tree.set("parameters/conditions/reload", reloading)
	
		
	# Head bobbing
	if !actions_disabled:
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
		shot_finished = false
		shooting = true
		
	if Input.is_action_just_pressed("reload") and bullet_count == 0 and bullet_reserve > 0 and gun_equipped:
		bullet_count += 1
		bullet_reserve -= 1
		reload_finished = false
		reloading = true
		
	# Crouching
	# if Input.is_action_pressed("crouch"):
		
		
	if !actions_disabled:
		move_and_slide()
	
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func gun_taken():
	bullet_reserve = 24
	gun_viewmodel.visible = true
	gun_equipped = true
	gun_sfx.stream = load(gun_sfx_lib[1])
	gun_sfx.play()
	
func _make_footstep():
	if groundray.is_colliding() and !actions_disabled:
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
	
func reload():
	reload_finished = true
	reloading = false
	
func shot():
	shot_finished = true
	shooting = false
	
func disable_actions():
	actions_disabled = true

func enable_actions():
	actions_disabled = false

func reset_gun() -> void:
	gun_viewmodel.visible = false
	gun_equipped = false
	
func death():
	var random_int = randi_range(0,4)
	feet_sfx.stream = load(death_sfx_lib[random_int])
	feet_sfx.play()
	print("DIEDIEDIEDIE")
	%game_manager/fade.restart_scene()
	
func fall():
	var random_int = randi_range(0,4)
	feet_sfx.stream = load(death_sfx_lib[random_int])
	feet_sfx.play()
	
