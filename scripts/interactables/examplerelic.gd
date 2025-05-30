extends Interactable

signal get_relic
var pieces_array : PackedScene


func _ready() -> void:
	reset_relic()

func _on_interacted(body):
	get_relic.emit()
	set_active(false)

func set_active(active: bool) -> void:
	# need to get the child mesh when available
	visible = active

func reset_relic():
	# get the current month to correlate to the index in pieces_array
	set_active(true)

