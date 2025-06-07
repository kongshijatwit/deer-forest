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


signal reset
# signal game_end

const BED_STRING: String = "bed"


func _ready() -> void:
	connect_signal(BED_STRING, "sleep", start_new_month)


func start_new_month() -> void:
	$fade.transition()
	reset.emit()
	if GlobalVariables.deer_killed >= 1:  # Remember to replace with 15
		GlobalVariables.villager_reputation = GlobalVariables.month + 1
		GlobalVariables.cultist_reputation = GlobalVariables.month * -1 - 1
	elif GlobalVariables.deer_killed < 1 and GlobalVariables.artifact_piece_collected:
		GlobalVariables.cultist_reputation += GlobalVariables.month + 1
		GlobalVariables.villager_reputation = GlobalVariables.month * -1 - 1
	GlobalVariables.artifact_piece_collected = false
	GlobalVariables.deer_killed = 0
	GlobalVariables.month += 1


func connect_signal(obj_string: String, sig_string: String, call_func: Callable) -> bool:
	var node = get_tree().root.get_child(2).find_child(obj_string)
	if node == null:
		push_warning("no " + obj_string + " found but that's okay")
		return false
	else:
		node.connect(sig_string, call_func)
		return true
