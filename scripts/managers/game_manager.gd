extends Node3D


signal reset
signal quest_complete

const REQUIRED_DEER_AMOUNT: int = 15

@onready var bed = %bed
@onready var relic = $"../relic"
@onready var player = %player
@onready var dialog_blocker = %dialog_blocker
@onready var deer_container: Node = $"../deer_container"


func _ready() -> void:
	bed.sleep.connect(start_new_month)
	relic.get_relic.connect(update_quest_status)
	dialog_blocker.finish_conversation.connect(end_game)
	player.dead.connect(on_player_dead)
	for deer: CharacterBody3D in deer_container.get_children():
		deer.get_node("deer_model/Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Root/pickup").deer_get.connect(update_quest_status)


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


func update_quest_status():
	if GlobalVariables.deer_killed >= REQUIRED_DEER_AMOUNT or GlobalVariables.artifact_piece_collected:
		quest_complete.emit()


func end_game():
	if GlobalVariables.month == 4:
		$fade2.transition_to_scene("res://scenes/main_menu.tscn")
		print("End of Game. THANKS FOR PLAYING")


func on_player_dead():
	GlobalVariables.deer_killed = 0
	GlobalVariables.artifact_piece_collected = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
