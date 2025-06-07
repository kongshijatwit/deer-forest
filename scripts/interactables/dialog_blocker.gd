extends Interactable

signal talking
signal done_talking

const TALK_PROMPT: String = "Talk"
@onready var dialog_controller: Node = $"../%dialogue_manager/MadTalk"
var finished_talking: bool = true


func _ready():
	prompt_message = TALK_PROMPT
	interacted.connect(begin_dialog)
	dialog_controller.dialog_finished.connect(finish_dialog)


func begin_dialog(_body):
	talking.emit()
	if finished_talking:
		prompt_message = ""
		if !GlobalVariables.villager_talked:
			MadTalkGlobals.set_variable("villager_reputation", GlobalVariables.villager_reputation)
			GlobalVariables.villager_talked = true
			finished_talking = false
			dialog_controller.start_dialog("villager")
		elif !GlobalVariables.cultist_talked:
			MadTalkGlobals.set_variable("cultist_reputation", GlobalVariables.cultist_reputation)
			GlobalVariables.cultist_talked = true
			finished_talking = false
			dialog_controller.start_dialog("cultist")
	

func finish_dialog(_sheet_name: Variant, _sequence_id: Variant):
	done_talking.emit()
	prompt_message = TALK_PROMPT
	finished_talking = true
	if GlobalVariables.villager_talked and GlobalVariables.cultist_talked:
		$CollisionShape3D.disabled = true
		visible = false


func reset_dialog_blocker():
	$CollisionShape3D.disabled = false
	visible = true

