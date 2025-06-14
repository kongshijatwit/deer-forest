extends Control

@onready var action_lbl = $HBoxContainer/Action_Label
@onready var keybind_lbl = $HBoxContainer/Keybind_Label

@export var action_name : String = "move_left"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()


func set_action_name() -> void:
	action_lbl.text = "Unassigned"
	
	match action_name:
		"forward":
			action_lbl.text = "Move Forward"
		"back":
			action_lbl.text = "Move Backward"
		"left":
			action_lbl.text = "Move Left"
		"right":
			action_lbl.text = "Move Right"
		"jump":
			action_lbl.text = "Jump"
		"crouch":
			action_lbl.text = "Crouch"
		"interact":
			action_lbl.text = "Interact"
		"reload":
			action_lbl.text = "Reload"
		"shoot":
			action_lbl.text = "Shoot"
			
func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	if action_event is InputEventKey:
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
		keybind_lbl.text = "%s" % action_keycode
	elif action_event is InputEventMouseButton:
		var action_mouse = action_event.button_index
		keybind_lbl.text = "Mouse Button %s" % str(action_mouse)
