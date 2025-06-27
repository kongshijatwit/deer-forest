extends Control


const DISPLAY_TIME_IN_SECONDS: float = 2.0

# References to child objects
@onready var objective1_checkbox: CheckBox = $"objective_container/objective_1"
@onready var objective2_checkbox: CheckBox = $"objective_container/objective_2"
@onready var or_text: RichTextLabel = $"objective_container/or_text"
@onready var timer: Timer = $"Timer"

# References to objectives signals
@onready var dialog_blocker = $"../../%dialog_blocker"
@onready var game_manager = $"../../%game_manager"
@onready var player = $"../../%player"
@onready var bed = $"../../%bed"
# Player or gun_item needs a gun_collected signal
# Game Manager needs a update_objectives signal
# Maybe have an array of objective strings and create/modify checkboxes at each index
# -- index gets incremented when an objective is completed

# Objectives variables
enum objectives {STRANGER_1 = 0, STRANGER_2, GUN, DEER, ARTIFACT, BED}
var objective_dict: Dictionary = {
	objectives.STRANGER_1: ["Talk to stranger", false],
	objectives.STRANGER_2: ["Talk to next stranger", false],
	objectives.GUN: ["Pick up gun", false],
	objectives.DEER: ["Pick up gun", false],
	objectives.ARTIFACT: ["Pick up gun", false],
	objectives.BED: ["Pick up gun", false]
}
var objective_pointer_1: int = 0
var objective_pointer_2: int = 4


func _ready():
	timer.wait_time = DISPLAY_TIME_IN_SECONDS
	dialog_blocker.done_talking.connect(update_talking_objective)
	game_manager.quest_complete.connect(update_hunt_objective)
	bed.sleep.connect(update_bed_objective)
	game_manager.reset.connect(reset_objectives)
	timer.timeout.connect(check_next_objective)
	update_objective_panel()


func update_talking_objective():
	if objective_dict[objectives.STRANGER_1][1]:
		objective_dict[objectives.STRANGER_2][1] = true
	else:
		objective_dict[objectives.STRANGER_1][1] = true
	check_objective()


func update_gun_objective():
	objective_dict[objectives.GUN][1] = true
	check_objective()


func update_hunt_objective():
	objective_dict[objectives.DEER][1] = true
	check_objective()


func update_bed_objective():
	objective_dict[objectives.BED][1] = true
	check_objective()


func reset_objectives():
	objective_pointer_1 = 0
	objective_pointer_2 = 4


func check_objective():
	if objective_dict[objective_pointer_1 as objectives][1]:
		objective1_checkbox.button_pressed = true
		timer.start()


func check_next_objective():
	objective_pointer_1 += 1
	if objective_pointer_1 > 3:
		objective_pointer_1 = 5
	update_objective_panel()
	check_objective()
	

func update_objective_panel():
	objective1_checkbox.button_pressed = false
	objective1_checkbox.text = objective_dict[objective_pointer_1 as objectives][0]


