extends Node

const ADVANCE_KEY: String = "ui_accept"
const INTERACT_KEY: String = "interact"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(ADVANCE_KEY) or Input.is_action_just_pressed(INTERACT_KEY):
		$MadTalk.dialog_acknowledge()
