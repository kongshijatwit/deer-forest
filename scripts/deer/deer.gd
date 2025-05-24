extends CharacterBody3D

@export var leash: Marker3D

enum STATE {IDLE = 0, WALK, GRAZE, SPOOK, RUN, DEAD}
const MIN_IDLE_TIME: float = 2.0
const MAX_IDLE_TIME: float = 2.5
const MAX_RUN_TIME: float = 5.0
const MAX_REACT_TIME: float = 0.35
const MIN_WALK_TIME: float = 1.0
const MAX_WALK_TIME: float = 3.5
const GAMEMANAGER_NAME: String = "game_manager"
const BOUNDARY_GROUP: String = "boundary"
const BULLET_GROUP: String = "bullet"

var gamemanager_node: Node = null

var spook_object_position := Vector3.ZERO
var current_state := STATE.IDLE
var idle_timer: float
var react_timer: float
var walk_timer: float
var run_timer: float

var run_direction: Vector3
var walk_speed: float = 100.0
var run_speed: float = 200

const DEBUG_MODE: bool = true


func _ready():
	reset_all_timers()
	add_gamemanager_signal()


func _process(delta: float) -> void:
	match current_state:
		STATE.IDLE:
			if idle_timer > 0:
				idle_timer -= delta
			else:
				current_state = (randi() % 3) as STATE
				if current_state == STATE.IDLE:
					pass
				elif current_state == STATE.WALK:
					rotate_y(deg_to_rad(randf_range(0.0, 360.0)))
				elif current_state == STATE.GRAZE:
					pass
				print_deer_state_change(STATE.IDLE)
				idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
			
		STATE.WALK:
			if walk_timer > 0:
				walk_timer -= delta
			else:
				current_state = STATE.IDLE
				walk_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
				velocity = Vector3.ZERO
				print_deer_state_change(STATE.WALK)

		STATE.GRAZE:
			current_state = STATE.IDLE
			print_deer_state_change(STATE.GRAZE)

		STATE.SPOOK:
			if react_timer > 0:
				react_timer -= delta
			else:
				current_state = STATE.RUN
				react_timer = MAX_REACT_TIME
				print_deer_state_change(STATE.SPOOK)

		STATE.RUN:
			if run_timer > 0:
				run_timer -= delta
			else:
				current_state = STATE.IDLE
				run_timer = MAX_RUN_TIME
				velocity = Vector3.ZERO
				print_deer_state_change(STATE.RUN)
		
		STATE.DEAD:
			# Set visibility to false instead of freeing it
			queue_free()
			

func _physics_process(delta: float) -> void:
	if current_state == STATE.RUN:
		velocity = run_direction * run_speed * delta

	elif current_state == STATE.WALK:
		velocity = transform.basis.z * walk_speed * delta  # Walk forward in local space
		
	move_and_slide()


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group(BULLET_GROUP):
		spook_object_position = area.get_parent().position
		run_direction = -(spook_object_position - global_position).normalized()
		run_direction.y = 0
		look_at(spook_object_position)
		rotation.x = rad_to_deg(0)
		current_state = STATE.SPOOK

	if area.is_in_group(BOUNDARY_GROUP):
		run_direction = (leash.position - global_position).normalized()
		spook_object_position = -leash.position
		run_direction.y = 0
		look_at(spook_object_position)
		rotation.x = rad_to_deg(0)
		current_state = STATE.SPOOK
	

func _on_deer_hit(area: Area3D) -> void:
	if area.is_in_group(BULLET_GROUP):
		await get_tree().create_timer(0.01).timeout
		var previous_state: STATE = current_state  # DEBUG VAR
		current_state = STATE.DEAD
		print_deer_state_change(previous_state)


func add_gamemanager_signal():
	var gamemanager: Node3D = get_tree().root.get_child(0).find_child(GAMEMANAGER_NAME)
	if gamemanager == null:
		push_warning("no bed found but that's okay")
	else:
		gamemanager.reset.connect(reset_deer)


func reset_deer():
	current_state = STATE.IDLE
	reset_all_timers()
	print(name + ": deer has been reset")


func print_deer_state_change(prev: STATE) -> void:
	if DEBUG_MODE:
		print("changing state: " + STATE.keys()[prev] + " -> " + STATE.keys()[current_state])
		if current_state == STATE.DEAD:
			print("dead")


func reset_all_timers() -> void:
	idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
	react_timer = MAX_REACT_TIME
	walk_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
	run_timer = MAX_RUN_TIME


