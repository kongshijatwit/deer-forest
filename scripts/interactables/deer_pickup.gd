extends Interactable

signal deer_get

@onready var deer_prefab = $"../../../../../../"
const PICKUP_PROMPT: String = "Pickup Deer"
var can_interact: bool = false


func _ready():
	$CollisionShape3D.disabled = true
	interacted.connect(pickup_deer)
	prompt_message = ""
	deer_prefab.deer_dead.connect(can_pickup)

func can_pickup() -> void:
	$CollisionShape3D.set_deferred("disabled", false)
	can_interact = true
	prompt_message = PICKUP_PROMPT

func pickup_deer(_body) -> void:
	if can_interact:
		can_interact = false
		# get_parent().visible = false
		deer_prefab.visible = false
		prompt_message = ""
		GlobalVariables.deer_killed += 1
		deer_get.emit()
