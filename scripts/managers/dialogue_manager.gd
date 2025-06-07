extends Node

const ADVANCE_KEY: String = "ui_accept"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(ADVANCE_KEY):
		$MadTalk.dialog_acknowledge()
