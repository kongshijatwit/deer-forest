extends Interactable

@export var ray_path := "/root/Main/NavigationRegion3D/Player/GroundRay"
@onready var door_sfx = $"../AudioStreamPlayer3D"
@onready var timer = $"../Timer"
@onready var game_manager: Node = $"../../%game_manager"
@onready var dialog_blocker: Node = $"../../%dialog_blocker"

var playback : AnimationNodeStateMachinePlayback
var is_open := false
var door_sfx_lib = ["res://assets/audio/sfx/door/A_Door_Close.ogg", "res://assets/audio/sfx/door/A_Door_Open.ogg", "res://assets/audio/sfx/door/A_Door_Knock.ogg"]
var ambiance_bus = AudioServer.get_bus_index("Ambiance")
var groundray
var talked = false
var knocked = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playback = $AnimationTree.get("parameters/playback")
	# groundray = get_node(ray_path)
	groundray = get_node("../%player/GroundRay")
	game_manager.reset.connect(reset_talk)
	dialog_blocker.talking.connect(talk)
	
func _process(_delta) -> void:
	if !is_open and !talked and !knocked:
		timer.wait_time = randf_range(3.0,5.0)
		timer.start()
		knocked = true
	if timer.get_time_left() < 1 and knocked:
		timer.stop()
		if !is_open:
			door_sfx.stream = load(door_sfx_lib[2])
			door_sfx.play()
		knocked = false
			

func toggle(_body):
	is_open = not is_open
	$CollisionShape3D.disabled = true
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
		
func talk() -> void:
	talked = true
	print("WHOOP WHOOP")

func reset_talk() -> void:
	talked = false


func _on_animation_player_animation_finished(_anim_name:StringName) -> void:
	$CollisionShape3D.disabled = false
