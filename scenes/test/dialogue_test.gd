extends Node3D

func _ready():
	$MadTalk.start_dialog("villager")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("crouch"):
		$MadTalk.dialog_acknowledge()

