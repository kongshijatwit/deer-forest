extends Node3D


@onready var deer_container: Node = $"../deer_container"

signal reset
signal quest_complete
# signal game_end

const BED_STRING: String = "bed"
const REQUIRED_DEER_AMOUNT: int = 1


func _ready() -> void:
	connect_signal(BED_STRING, "sleep", start_new_month)
	connect_signal("relic", "get_relic", update_quest_status)
	connect_signal("dialog_blocker", "finish_conversation", end_game)
	for deer: CharacterBody3D in deer_container.get_children():
		deer.get_node("StaticBody3D").deer_get.connect(update_quest_status)
		# deer.deer_get.connect(update_quest_status)


func start_new_month() -> void:
	$fade.transition()
	if GlobalVariables.deer_killed >= REQUIRED_DEER_AMOUNT:  # Remember to replace with 15
		GlobalVariables.villager_reputation = GlobalVariables.month + 1
		GlobalVariables.cultist_reputation = GlobalVariables.month * -1 - 1
	elif GlobalVariables.deer_killed < REQUIRED_DEER_AMOUNT and GlobalVariables.artifact_piece_collected:
		GlobalVariables.cultist_reputation = GlobalVariables.month + 1
		GlobalVariables.villager_reputation = GlobalVariables.month * -1 - 1
	GlobalVariables.artifact_piece_collected = false
	GlobalVariables.deer_killed = 0
	GlobalVariables.month += 1
	reset.emit()


func connect_signal(obj_string: String, sig_string: String, call_func: Callable) -> bool:
	var node = get_tree().root.get_child(2).find_child(obj_string)
	if node == null:
		push_warning("no " + obj_string + " found but that's okay")
		return false
	else:
		node.connect(sig_string, call_func)
		return true


func update_quest_status():
	# print("deer killed: " + str(GlobalVariables.deer_killed) + " vs. artifact coll:" + str(GlobalVariables.artifact_piece_collected))
	if GlobalVariables.deer_killed >= REQUIRED_DEER_AMOUNT or GlobalVariables.artifact_piece_collected:
		quest_complete.emit()


func end_game():
	if GlobalVariables.month == 4:
		print("End of Game. THANKS FOR PLAYING")
