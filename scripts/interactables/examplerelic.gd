extends Interactable

signal get_relic

@onready var game_manager: Node = $"../%game_manager"
var pieces_array : PackedScene


func _ready() -> void:
	interacted.connect(on_interacted)
	game_manager.reset.connect(reset_relic)


func on_interacted(_body):
	# get_relic.emit()
	GlobalVariables.artifact_piece_collected = true
	GlobalVariables.artifact_pieces_gathered += 1
	set_active(false)


func set_active(active: bool) -> void:
	$CollisionShape3D.disabled = !active
	visible = active
	

func reset_relic():
	# get the current month to correlate to the index in pieces_array
	set_active(true)

