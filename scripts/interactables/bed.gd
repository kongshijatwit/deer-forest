extends Interactable

signal sleep()

const SLEEP_PROMPT: String = "Go to sleep"
var can_use: bool = true

func _ready() -> void:
	# TODO: Take in another signal that resets `can_use`
	prompt_message = SLEEP_PROMPT
	interacted.connect(on_bed_interacted)

func on_bed_interacted(body):
	if can_use:
		can_use = false
		sleep.emit()
		prompt_message = ""
	# Maybe call a body.reset() function in the player that interacts with the bed to reset bullets?
	print("yeah")

func allow_sleep():
	can_use = true
	prompt_message = SLEEP_PROMPT