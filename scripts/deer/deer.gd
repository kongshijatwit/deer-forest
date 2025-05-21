extends CharacterBody3D

enum STATE {IDLE = 0, WALK, GRAZE, SPOOK, RUN}
const MAX_RUN_TIME: float = 5.0
const MAX_REACT_TIME: float = 0.35
const MIN_WALK_TIME: float = 1.0
const MAX_WALK_TIME: float = 5.0

var spook_object_position := Vector3.ZERO
var current_state := STATE.IDLE
var react_timer: float
var walk_timer: float
var run_timer: float

var walk_speed: float = 100.0
var run_speed: float = 200

# deer should despawn after entering certain zone

func _ready():
    react_timer = MAX_REACT_TIME
    walk_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
    run_timer = MAX_RUN_TIME
    pass

func _process(delta: float) -> void:
    match current_state:
        STATE.IDLE:
            # 50% chance it walks
            # 50% chance to graze
            print("idle")

        STATE.WALK:
            if react_timer > 0:
                react_timer -= delta
            else:
                current_state = STATE.RUN
                react_timer = MAX_REACT_TIME

        STATE.GRAZE:
            print("grazing")

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
        var direction := Vector3(randf(), 0, randf())
        velocity = direction * run_speed * delta
        
    move_and_slide()


func _on_area_entered(area: Area3D) -> void:
    print("bullet position " + str(area.get_parent().position.z));
    spook_object_position = area.get_parent().position
    current_state = STATE.SPOOK
