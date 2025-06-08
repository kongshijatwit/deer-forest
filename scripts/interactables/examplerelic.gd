extends Interactable

signal get_relic

@onready var game_manager: Node = $"../%game_manager"
var pieces_array : PackedScene


func _ready() -> void:
	interacted.connect(on_interacted)
	game_manager.reset.connect(reset_relic)
	reset_relic()


func on_interacted(_body):
	GlobalVariables.artifact_piece_collected = true
	GlobalVariables.artifact_pieces_gathered += 1
	get_relic.emit()
	set_active(false)


func set_active(active: bool) -> void:
	$CollisionShape3D.disabled = !active
	visible = active
	

func reset_relic():
	for piece in $DividedScroll.get_children():
		piece.visible = false
	print("month: " + str(GlobalVariables.month))
	print($DividedScroll.get_child(GlobalVariables.month).name)
	$DividedScroll.get_child(GlobalVariables.month).visible = true
	set_active(true)

