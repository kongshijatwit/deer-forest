extends Interactable


@onready var dialog_controller: Node = %dialog_manager/MadTalk
var finished_talking: bool = true


func _ready():
	prompt_message = "Talk"
	interacted.connect(begin_dialog)
	dialog_controller.dialog_finished.connect()


func begin_dialog(_body):
	if finished_talking:
		prompt_message = ""
		if !GlobalVariables.villager_talked:
			GlobalVariables.villager_talked = true
			finished_talking = false
			dialog_controller.start_dialog("villager")
		elif !GlobalVariables.cultist_talked:
			GlobalVariables.cultist_talked = true
			finished_talking = false
			dialog_controller.start_dialog("cultist")
	
	
func finish_dialog(_sheet_name: Variant, _sequence_id: Variant):
	prompt_message = "Talk"
	finished_talking = true

