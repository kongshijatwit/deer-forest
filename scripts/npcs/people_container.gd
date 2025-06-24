extends Node3D

@onready var dialog_blocker = %dialog_blocker
@onready var game_manager = %game_manager
@onready var animation_player = $AnimationPlayer
var first_convo_done: bool = false


func _ready():
	dialog_blocker.done_talking.connect(move_people)
	game_manager.reset.connect(reset_people)

func move_people():
	if !first_convo_done:
		animation_player.play("move_villager")
		first_convo_done = true
	else:
		animation_player.play("move_cultist")

func reset_people():
	first_convo_done = false
	animation_player.play("RESET")
