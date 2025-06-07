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

@onready var deer_container: Node = $"../deer_container"

signal reset
signal quest_complete
# signal game_end

const BED_STRING: String = "bed"
const REQUIRED_DEER_AMOUNT: int = 1


func _ready() -> void:
	connect_signal(BED_STRING, "sleep", start_new_month)
	connect_signal("relic", "get_relic", update_quest_status)
	for deer: CharacterBody3D in deer_container.get_children():
		# print(deer.get_node("StaticBody3D").name)
		deer.deer_get.connect(update_quest_status)


func start_new_month() -> void:
	$fade.transition()
	reset.emit()
	if GlobalVariables.deer_killed >= REQUIRED_DEER_AMOUNT:  # Remember to replace with 15
		GlobalVariables.villager_reputation = GlobalVariables.month + 1
		GlobalVariables.cultist_reputation = GlobalVariables.month * -1 - 1
	elif GlobalVariables.deer_killed < REQUIRED_DEER_AMOUNT and GlobalVariables.artifact_piece_collected:
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


func update_quest_status():
	print("update")
	print("deer killed: " + str(GlobalVariables.deer_killed) + " vs. artifact coll:" + str(GlobalVariables.artifact_piece_collected))
	if GlobalVariables.deer_killed >= REQUIRED_DEER_AMOUNT or GlobalVariables.artifact_piece_collected:
		quest_complete.emit()
