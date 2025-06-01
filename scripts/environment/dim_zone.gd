extends Node3D

var original_world_env: WorldEnvironment
var dim_world_env: WorldEnvironment


func _ready():
	dim_world_env = $WorldEnvironment
	# original_world_env = get_node("/../WorldEnvvironment")
	$Area3D.area_entered.connect(dim_zone_entered)

func dim_zone_entered():
	pass
