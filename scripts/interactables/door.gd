extends Interactable

var playback : AnimationNodeStateMachinePlayback
var is_open := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playback = $AnimationTree.get("parameters/playback")

func toggle(_body):
	is_open = not is_open
	
	if is_open:
		playback.travel("DoorOpen")
		prompt_message = "Close Door"
	else:
		playback.travel("DoorClose")
		prompt_message = "Open Door"
