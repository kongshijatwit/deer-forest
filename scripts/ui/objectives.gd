extends Control

# Objectives
# --> Talk to strangers
# --> Pick up gun
# --> Hunt 15 deer OR Collect Artifact

@onready var objective1_checkbox: CheckBox = $"objective_container/objective_1"
@onready var objective2_checkbox: CheckBox = $"objective_container/objective_2"

@onready var dialog_blocker = $"../../%dialog_blocker"
@onready var game_manager = $"../../%game_manager"
@onready var player = $"../../%player"
@onready var bed = $"../../%bed"
# Player or gun_item needs a gun_collected signal
# Game Manager needs a update_objectives signal
# Maybe have an array of objective strings and create/modify checkboxes at each index
# -- index gets incremented when an objective is completed

const OBJECTIVES: Array[String] = ["Talk to stranger", "Talk to next stranger", "Pick up gun", "Hunt 15 deer", "Collect artifact", "Go to bed"]
var objective_pointer_1: int = 0
var objective_pointer_2: int = 4

# objectives (might not need)
var talked_to_stranger_1: bool = false
var talked_to_stranger_2: bool = false
var picked_up_gun: bool = false
var finish_deer: bool = false
var finish_artifact: bool = false
var sleeping: bool = false


func _ready():
	dialog_blocker.done_talking.connect(update_talking_objective)
	game_manager.quest_complete.connect(update_hunt_objective)
	bed.sleep.connect(update_bed_objective)
	game_manager.reset.connect(reset_objectives)


func update_talking_objective():
	objective_pointer_1 += 1
	update_objective_panel()
	# if talked_to_stranger_1:
	# 	talked_to_stranger_2 = true
	# else:
	# 	talked_to_stranger_1 = true
	


func update_gun_objective():
	objective_pointer_1 += 1
	update_objective_panel()
	picked_up_gun = true


func update_hunt_objective():
	if GlobalVariables.deer_killed >= game_manager.REQUIRED_DEER_AMOUNT:
		finish_deer = true
		objective_pointer_1 = OBJECTIVES.back()
		update_objective_panel()
	elif GlobalVariables.artifact_piece_collected:
		objective_pointer_2 = OBJECTIVES.back()
		update_objective_panel()
		finish_artifact = true

func update_bed_objective():
	sleeping = true

func reset_objectives():
	talked_to_stranger_1 = false
	talked_to_stranger_2 = false
	picked_up_gun = false
	finish_deer = false
	finish_artifact = false
	sleeping = false
	objective_pointer_1 = 0
	objective_pointer_2 = 4

func update_objective_panel():
	objective1_checkbox.text = OBJECTIVES[objective_pointer_1]
	# objective2_checkbox.text = OBJECTIVES[objective_pointer_2]
	if objective_pointer_1 == 3:
		objective2_checkbox.visible = true




