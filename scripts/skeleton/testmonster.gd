extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5
var skeleton_state_machine 
var player_detected = false
var timer_started = false
var walk_done = true
var turn_done = false
var dead = false

@onready var ray = $RayCast3D
@onready var head = $Humanoid/Skeleton3D/Head
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../Player"
@onready var timer = $Timer



func _ready():
	skeleton_state_machine = anim_tree.get("parameters/playback")
		

func _process(delta: float) -> void:
	ray.rotation = head.rotation
	ray.transform = head.transform
	
	match skeleton_state_machine.get_current_node():
		"run":
			walk_done = true
			print(timer.get_time_left())
			if ray.get_collider() != player and !timer_started:
				timer.set_paused(false)
				timer.start()
				timer_started = true
			if timer.get_time_left() < 1:
				timer.stop()
				player_detected = false
			if ray.get_collider() == player:
				timer_started = false
				timer.set_paused(true)

			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 10.0)
			move_and_slide()
		"walk":
			if !turn_done:
				var angle = randf_range(0.0, 360.0)
				nav_agent.set_target_position(global_position + Vector3(5 * cos(angle), 0, 5 * sin(angle)))
				turn_done = true
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 10.0)
			move_and_slide()
		"idle":
			turn_done = false
			
			
			
		
					
					
	anim_tree.set("parameters/conditions/run", _player_detection())
	anim_tree.set("parameters/conditions/idle", !player_detected)
	anim_tree.set("parameters/conditions/dead", dead)
	
	
		
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
		dead = true
