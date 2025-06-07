extends Interactable

signal sleep

const SLEEP_PROMPT: String = "Go to sleep"

@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D
var can_use: bool = true


func _ready() -> void:
	# TODO: Take in another signal that resets `can_use`
	prompt_message = SLEEP_PROMPT
	interacted.connect(on_bed_interacted)

func on_bed_interacted(_body):
	if can_use:
		can_use = false
		sleep.emit()
		audio_stream.play()
		prompt_message = ""
	else:
		print("sleep unavailable")
	# call a body.reset() function in the player that interacts with the bed to reset bullets?
	

func allow_sleep():
	can_use = true
	prompt_message = SLEEP_PROMPT