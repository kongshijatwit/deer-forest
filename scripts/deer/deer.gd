extends CharacterBody3D

enum STATE {IDLE = 0, WALK, GRAZE, SPOOK, RUN, DEAD}
const MIN_IDLE_TIME: float = 2.0
const MAX_IDLE_TIME: float = 2.5
const MAX_RUN_TIME: float = 5.0
const MAX_REACT_TIME: float = 0.35
const MIN_WALK_TIME: float = 1.0
const MAX_WALK_TIME: float = 3.5

var spook_object_position := Vector3.ZERO
var current_state := STATE.IDLE
var idle_timer: float
var react_timer: float
var walk_timer: float
var run_timer: float

var walk_direction: Vector3
var run_direction: Vector3
var walk_speed: float = 100.0
var run_speed: float = 200

# deer should despawn after entering certain zone

func _ready():
    idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
    react_timer = MAX_REACT_TIME
    walk_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
    run_timer = MAX_RUN_TIME


func _process(delta: float) -> void:
    match current_state:
        STATE.IDLE:
            # 33% chance it walks
            # 33% chance to graze
            # 33% chance it continues idling
            print("idle")
            if idle_timer > 0:
                idle_timer -= delta
            else:
                current_state = (randi() % 3) as STATE
                if current_state == STATE.IDLE:
                    print("keep idling")
                elif current_state == STATE.WALK:
                    walk_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
                idle_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
            
        STATE.WALK:
            print("walking")
            if walk_timer > 0:
                walk_timer -= delta
            else:
                current_state = STATE.IDLE
                walk_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
                velocity = Vector3.ZERO

        STATE.GRAZE:
            print("grazing")
            current_state = STATE.IDLE

        STATE.SPOOK:
            print("spooking")
            if react_timer > 0:
                react_timer -= delta
            else:
                current_state = STATE.RUN
                react_timer = MAX_REACT_TIME

        STATE.RUN:
            print("running")
            if run_timer > 0:
                run_timer -= delta
            else:
                current_state = STATE.IDLE
                run_timer = MAX_RUN_TIME
                velocity = Vector3.ZERO
        


func _physics_process(delta: float) -> void:
    if current_state == STATE.RUN:
        var direction: Vector3 = -(spook_object_position - global_position).normalized()
        direction.y = 0
        velocity = direction * run_speed * delta

    elif current_state == STATE.WALK:
        velocity = walk_direction * run_speed * delta
        
    move_and_slide()


func _on_area_entered(area: Area3D) -> void:
    print("bullet position " + str(area.get_parent().position.z));
    spook_object_position = area.get_parent().position
    run_direction = -(spook_object_position - global_position).normalized()
    current_state = STATE.SPOOK
    # area.get_parent().queue_free()
