extends CharacterBody3D


const ATTACK_RANGE = 2
const SPEED = 1.0
const RUN_SPEED = 5.1
const JUMP_VELOCITY = 4.5
const BONES_TIMER: float = 4.5
var skeleton_state_machine 
var player_detected = false
var timer_started = false
var walk_done = true
var turn_done = false
var dead = false
var last_position: Vector3
var bones_despawn_timer: float
var gamble = 1
var has_gambled = false

@onready var ray = $RayCast3D
@onready var head = $Humanoid/Skeleton3D/Head
@onready var phys_skel = $Humanoid/Skeleton3D/PhysicalBoneSimulator3D
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../Player"
@onready var timer = $Timer

# var dummy_prefab: PackedScene = load("res://prefabs/skeleton/ragdoll_skeleton_test.tscn")


func _ready():
	bones_despawn_timer = BONES_TIMER
	skeleton_state_machine = anim_tree.get("parameters/playback")
		

func _process(delta: float) -> void:
	if !(skeleton_state_machine.get_current_node() == "Secret"):
		ray.rotation = head.rotation
		ray.transform = head.transform
	
	match skeleton_state_machine.get_current_node():
		"Run":
			run(delta)
		"Secret":
			run(delta)
		"Walk":
			if !turn_done:
				var angle = randf_range(0.0, 360.0)
				nav_agent.set_target_position(global_position + Vector3(5 * cos(angle), 0, 5 * sin(angle)))
				turn_done = true
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 10.0)
			move_and_slide()
		"Idle":
			turn_done = false
			if !has_gambled:
				gamble = randi_range(1,2)
				has_gambled = true
		"Punch":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP, true)
	if Input.is_action_just_pressed("ui_down"):
		reset_ragdoll()
		set_active(true)
		position = last_position
		anim_tree.set("parameters/conditions/idle", true)
		dead = false
		bones_despawn_timer = BONES_TIMER
		$Humanoid.visible = true

	if dead and $Humanoid.visible:
		if bones_despawn_timer > 0:
			bones_despawn_timer -= delta
		else:
			print("SET FALSE NOW")
			$Humanoid.visible = false

	anim_tree.set("parameters/conditions/run", _player_detection() and gamble == 1)
	anim_tree.set("parameters/conditions/secret", _player_detection() and gamble > 1)
	anim_tree.set("parameters/conditions/punch", _target_in_range() and !player.crouching)
	anim_tree.set("parameters/conditions/kick", _target_in_range() and player.crouching)
	anim_tree.set("parameters/conditions/idle", !player_detected)
	anim_tree.set("parameters/conditions/dead", dead)
	
	
# Checks if player is detected
func _player_detection():
	if ray.is_colliding():
		if ray.get_collider() == player:
			player_detected = true
			return true
	else:
		return false
	
# Death
func _on_area_3d_area_entered(area: Area3D) -> void:
	print("Skeleboned")
	if area.is_in_group("bullet"):
		print("Skeleboned by bullet")
		last_position = position
		start_ragdoll()
		set_active(false)
		dead = true

func set_active(active: bool):
	$CollisionShape3D.set_deferred("disabled", !active)
	$Area3D/CollisionShape3D.set_deferred("disabled", !active)
	anim_player.active = active
	anim_tree.active = active

func start_ragdoll():
	phys_skel.active = true
	phys_skel.physical_bones_start_simulation()
	await get_tree().create_timer(3.0).timeout

func reset_ragdoll():
	$Humanoid/Skeleton3D.reset_bone_poses()
	phys_skel.physical_bones_stop_simulation()
	phys_skel.active = false

func run(delta):
	walk_done = true
#	print(timer.get_time_left())
	if ray.get_collider() != player and !timer_started:
		timer.set_paused(false)
		timer.start()
		timer_started = true
	if timer.get_time_left() < 1:
		timer.stop()
		player_detected = false
		has_gambled = false
	if ray.get_collider() == player:
		timer_started = false
		timer.set_paused(true)
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * RUN_SPEED
	rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 10.0)
	move_and_slide()

# Player in hit range
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
# Attack landed
func _hit_finished():
	player.hit(50, global_transform.origin)
