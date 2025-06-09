extends Interactable

signal sleep

const SLEEP_PROMPT: String = "Go to sleep"

@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D
var can_use: bool = false


func _ready() -> void:
	prompt_message = ""
	interacted.connect(on_bed_interacted)
	var game_manager: Node3D = %game_manager
	game_manager.quest_complete.connect(allow_sleep)

func on_bed_interacted(_body):
	if can_use:
		can_use = false
		audio_stream.play()
		prompt_message = ""
		_body.disable_actions()
		sleep.emit()
	else:
		print("sleep unavailable")
	# call a body.reset() function in the player that interacts with the bed to reset bullets?
	

func allow_sleep():
	can_use = true
	prompt_message = SLEEP_PROMPT