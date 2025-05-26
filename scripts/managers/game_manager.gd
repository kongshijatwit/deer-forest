extends Node3D

# Questions:
#  - How many total months?
#  - Do bullets correlate to amount of deer/monsters

# Cannot go to sleep unless one of the two conditions are met
# - Killed enough deer
# - Collected the artifact piece

signal reset
const BED_STRING: String = "bed"
var month: int = 0
var deer_killed: int = 0
var artifact_piece_collected: bool = false


func _ready() -> void:
	var bed_node: Node3D = get_tree().root.get_child(1).find_child(BED_STRING)
	if bed_node == null:
		push_warning("no bed found but that's okay")
	else:
		bed_node.sleep.connect(start_new_month)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		print(month)


func start_new_month() -> void:
	# reset monster/deer spawns
	$fade.transition()
	reset.emit()
	month += 1
