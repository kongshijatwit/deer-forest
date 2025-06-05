extends Interactable


const PICKUP_PROMPT: String = "Pickup Deer"
var can_interact: bool = false


func _ready():
	interacted.connect(pickup_deer)
	prompt_message = ""
	get_parent().deer_dead.connect(can_pickup)

func can_pickup() -> void:
	can_interact = true
	prompt_message = PICKUP_PROMPT

func pickup_deer(_body) -> void:
	if can_interact:
		can_interact = false
		get_parent().get_node("deer_model").visible = false
		prompt_message = ""
		GlobalVariables.deer_killed += 1
