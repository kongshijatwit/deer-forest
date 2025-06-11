extends Node3D

var gun_state_machine

@onready var player = $"../../../../../../.."
@onready var gun_anim_tree = $AnimationTree

func _ready():
	gun_state_machine = gun_anim_tree.get("parameters/playback")
	
func _process(delta: float) -> void:
	match gun_state_machine.get_current_node():
		"Reload":
			gun_anim_tree.set("parameters/conditions/shoot", false)
		"IdleUncocked":
			gun_anim_tree.set("parameters/conditions/idle", false)
	

func _reload_finished():
	player.reload()
