extends Node3D

# [x] Create bed interactable object
# [x] Need to get bed emitted signal when player interacts with bed, call start_new_month()
# [ ] Fade to black -> Increment month and respawn deer + monsters -> "A new month has begun, bringing more deer"
#

# Questions:
#  - How many total months?
#  - Do bullets correlate to amount of deer/monsters

signal reset
const BED_STRING: String = "bed"
var month: int = 0


func _ready() -> void:
	print("this is your president speaking")
	var bed_node: Node3D = $"../".find_child(BED_STRING)
	if bed_node == null:
		push_warning("no bed found but that's okay")
	else:
		bed_node.sleep.connect(start_new_month)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		print(month)


func start_new_month() -> void:
	# reset monster/deer spawns
	reset.emit()
	month += 1

