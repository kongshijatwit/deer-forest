extends Node3D

# Questions:
#  - How many total months?
#  - Do bullets correlate to amount of deer/monsters

# Cannot go to sleep unless one of the two conditions are met
# - Killed enough deer
# - Collected the artifact piece

# This class is reponsible for:
# - Determining the start AND end of the game
# - Progressing the game forward through months
# - Resetting the game when a new month begins


@export var deer_container: Node3D

signal reset
signal game_end

const BED_STRING: String = "bed"
const RELIC_STRING: String = "ExampleRelic"

var month: int = 0
var deer_killed: int = 0
var artifact_piece_collected: bool = false



func _ready() -> void:
	connect_signal(BED_STRING, "sleep", start_new_month)
	connect_signal(RELIC_STRING, "get_relic", artifact_collected)
	if deer_container != null:
		for deer: Node3D in deer_container.get_children():
			# deer.dead.connect(increment_dead_deer)
			pass
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		print(month)


func start_new_month() -> void:
	# reset monster/deer spawns
	$fade.transition()
	reset.emit()
	artifact_piece_collected = false
	deer_killed = 0
	month += 1


func artifact_collected() -> void:
	print("collected artifact")
	artifact_piece_collected = true


func increment_dead_deer() -> void:
	deer_killed += 1


func connect_signal(obj_string: String, sig_string: String, call_func: Callable) -> bool:
	var node = get_tree().root.get_child(1).find_child(obj_string)
	if node == null:
		push_warning("no bed found but that's okay")
		return false
	else:
		node.connect(sig_string, call_func)
		return true

