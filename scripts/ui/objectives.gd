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

# Objectives variables
enum objectives {STRANGER_1 = 0, STRANGER_2, GUN, DEER, ARTIFACT, BED}
var objective_dict: Dictionary = {
	objectives.STRANGER_1: ["Talk to stranger", false],
	objectives.STRANGER_2: ["Talk to next stranger", false],
	objectives.GUN: ["Pick up gun", false],
	objectives.DEER: ["Hunt 15 deer", false],
	objectives.ARTIFACT: ["Collect Artifact", false],
	objectives.BED: ["Go to bed", false]
}
var objective_pointer_1: int = 0
var objective_pointer_2: int = 4


func _ready():
	timer.wait_time = DISPLAY_TIME_IN_SECONDS
	dialog_blocker.done_talking.connect(update_talking_objective)
	game_manager.quest_complete.connect(complete_hunt_objective)
	bed.sleep.connect(complete_bed_objective)
	game_manager.reset.connect(reset_objectives)
	timer.timeout.connect(check_next_objective)
	player.objective_gun.connect(complete_gun_objective)
	game_manager.objective_update.connect(update_hunt_objective)
	update_objective_panel()


func update_talking_objective():
	if objective_dict[objectives.STRANGER_1][1]:
		objective_dict[objectives.STRANGER_2][1] = true
	else:
		objective_dict[objectives.STRANGER_1][1] = true
	check_objective()


func complete_gun_objective():
	objective_dict[objectives.GUN][1] = true
	check_objective()


func update_hunt_objective():
	update_objective_panel()


func complete_hunt_objective():
	if GlobalVariables.deer_killed >= game_manager.REQUIRED_DEER_AMOUNT:
		objective_dict[objectives.DEER][1] = true
	elif GlobalVariables.artifact_piece_collected:
		objective_dict[objectives.ARTIFACT][1] = true
	check_objective()


func complete_bed_objective():
	objective_dict[objectives.BED][1] = true
	check_objective()


func reset_objectives():

	# Reset objective pointers
	objective_pointer_1 = 0
	objective_pointer_2 = 4

	# Reset objective-complete booleans
	for key in objective_dict:
		objective_dict[key][1] = false

	# Reset checkboxes
	objective1_checkbox.button_pressed = false
	objective2_checkbox.button_pressed = false
	objective2_checkbox.disabled = false
	update_objective_panel()
	


func check_objective():

	# First objective completed
	if objective_dict[objective_pointer_1 as objectives][1]:
		if objective_pointer_1 == 3:
			objective2_checkbox.disabled = true
			objective_pointer_1 += 1
		objective1_checkbox.button_pressed = true
		objective_pointer_1 += 1
		timer.start()
	
	# Second objective completed
	if objective_dict[objective_pointer_2 as objectives][1]:
		objective2_checkbox.button_pressed = true
		objective_pointer_2 += 1
		timer.start()


func check_next_objective():

	# Reset checkbox pressed status
	objective1_checkbox.button_pressed = false
	objective2_checkbox.button_pressed = false

	# Update objective text, checkbox visibility, etc.
	update_objective_panel()

	# Check if future objective is completed
	check_objective()
	

func update_objective_panel():

	# Update text in first objective checkbox corresponding to dictionary
	objective1_checkbox.text = objective_dict[objective_pointer_1 as objectives][0]
	
	if objective_pointer_1 == 3:
		# Update deer counter and artifact transition to bed objective
		objective1_checkbox.text = objective_dict[objective_pointer_1 as objectives][0] + ": " + str(GlobalVariables.deer_killed) + "/" + str(game_manager.REQUIRED_DEER_AMOUNT)
		objective2_checkbox.text = objective_dict[objective_pointer_2 as objectives][0]
		
		# Don't need to make visible if already visible
		if !objective2_checkbox.visible:
			or_text.visible = true
			objective2_checkbox.visible = true
	
	# When deer objective is completed, turn off or-text and second objective checkbox
	if objective_pointer_1 == 5:
		or_text.visible = false
		objective2_checkbox.visible = false
