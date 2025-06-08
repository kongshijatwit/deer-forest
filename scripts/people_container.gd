extends Node3D


@onready var dialog_blocker = %dialog_blocker
@onready var game_manager = %game_manager

const MOVE_AMOUNT: float = 5.3
var can_move: bool = false
var first_convo: bool = false
var new_x_position: float


func _ready():
	dialog_blocker.done_talking.connect(start_lerp)
	game_manager.reset.connect(reset_people)
	new_x_position = position.x + MOVE_AMOUNT

func _process(delta):
	if can_move:
		position.x += 10.0 * delta
		if position.x > new_x_position:
			can_move = false
			if first_convo:
				visible = false
			else:
				first_convo = true
	
func start_lerp():
	new_x_position = position.x + MOVE_AMOUNT
	can_move = true

func reset_people():
	visible = true
	first_convo = false
	position.x = 0

