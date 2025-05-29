extends Interactable

@export var ray_path := "/root/Main/NavigationRegion3D/Player/GroundRay"
@onready var door_sfx = $"../AudioStreamPlayer3D"

var playback : AnimationNodeStateMachinePlayback
var is_open := false
var door_sfx_lib = ["res://assets/audio/sfx/door/A_Door_Close.ogg", "res://assets/audio/sfx/door/A_Door_Open.ogg"]
var ambiance_bus = AudioServer.get_bus_index("Ambiance")
var groundray

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playback = $AnimationTree.get("parameters/playback")
	groundray = get_node(ray_path)

func toggle(_body):
	is_open = not is_open
	
	if is_open:
		door_sfx.stream = load(door_sfx_lib[1])
		door_sfx.play()
		AudioServer.set_bus_effect_enabled(ambiance_bus, 0, false)
		playback.travel("DoorOpen")
		prompt_message = "Close Door"
	else:
		door_sfx.stream = load(door_sfx_lib[0])
		door_sfx.play()
		playback.travel("DoorClose")
		prompt_message = "Open Door"

func _shelter():
	if groundray.is_colliding():
		if groundray.get_collider().is_in_group("wood"):
			print("NO WIND!")
			AudioServer.set_bus_effect_enabled(ambiance_bus, 0, true)
		
