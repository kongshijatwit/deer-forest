extends Interactable

signal talking
signal done_talking
signal finish_conversation

const TALK_PROMPT: String = "Talk"
@onready var dialog_controller: Node = $"../%dialogue_manager/MadTalk"
@onready var game_manager: Node = $"../%game_manager"
var finished_talking: bool = true
var villager_talked: bool = false
var cultist_talked: bool = false

@onready var sfx_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
var villager_sfx = "res://assets/audio/sfx/dialogue/A_Voice.ogg"
var cultist_sfx = "res://assets/audio/sfx/dialogue/A_Voice_Cult.ogg"


func _ready():
	prompt_message = TALK_PROMPT
	interacted.connect(begin_dialog)
	dialog_controller.dialog_finished.connect(finish_dialog)
	game_manager.reset.connect(reset_dialog_blocker)


func begin_dialog(_body):
	talking.emit()
	if finished_talking:
		prompt_message = ""
		if !villager_talked:
			MadTalkGlobals.set_variable("villager_reputation", GlobalVariables.villager_reputation)
			villager_talked = true
			finished_talking = false
			dialog_controller.start_dialog("villager")
			sfx_player.stream = load(villager_sfx)
		elif !cultist_talked:
			MadTalkGlobals.set_variable("cultist_reputation", GlobalVariables.cultist_reputation)
			cultist_talked = true
			finished_talking = false
			dialog_controller.start_dialog("cultist")
			sfx_player.stream = load(cultist_sfx)
		sfx_player.play()
	

func finish_dialog(_sheet_name: Variant, _sequence_id: Variant):
	done_talking.emit()
	prompt_message = TALK_PROMPT
	finished_talking = true
	if villager_talked and cultist_talked:
		finish_conversation.emit()
		$CollisionShape3D.disabled = true
		visible = false


func reset_dialog_blocker():
	villager_talked = false
	cultist_talked = false
	$CollisionShape3D.disabled = false
	visible = true
