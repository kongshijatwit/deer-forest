extends Node3D

# track "months" spent
# [x] Create bed interactable object
# [] Interacting will increment months : PROBLEM - Player can spam-click bed
# [] Fade to black -> Increment month and respawn deer + monsters
#
# reset/track deer and monster spawn

# Questions:
#  - How many total months?
#  - Do bullets correlate to amount of deer/monsters

const BED_PATH: String = "bed"

func _ready() -> void:
	print("this is your president speaking")
	var bed_var: Node3D = $"../".find_child(BED_PATH)
	if bed_var == null:
		push_warning("no cool var but that's okay")
	else:
		bed_var.interacted.connect(on_new_month)


func _process(delta: float) -> void:
	pass

func on_new_month(body) -> void:
	print("a new month has passed")

