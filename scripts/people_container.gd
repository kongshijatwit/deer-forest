extends Node3D


@onready var dialog_blocker = %dialog_blocker
var can_move: bool = false
var first_convo: bool = false
var move_amount: float


func _ready():
	dialog_blocker.done_talking.connect(start_lerp)
	move_amount = position.x + 5.3


func _process(delta):
	if can_move:
		position.x += 10.0 * delta
		if position.x > move_amount:
			can_move = false
			if first_convo:
				visible = false
			else:
				first_convo = true
	

func start_lerp():
	move_amount = position.x + 5.3
	can_move = true

