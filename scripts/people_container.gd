extends Node3D


@onready var dialog_blocker = %dialog_blocker
var can_move: bool = false
var move_amount: float


func _ready():
	dialog_blocker.done_talking.connect(start_lerp)
	move_amount = position.x + 10.0


func _process(delta):
	if can_move:
		lerp(position.x, move_amount, delta)
		if position.x == move_amount:
			can_move = false
	

func start_lerp():
	can_move = true