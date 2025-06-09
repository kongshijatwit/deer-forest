extends Node3D

const ORIGINAL_VFEE: float = 1.0
const ORIGINAL_VFD: float = 0.01
const DEEP_FOREST_VFEE: float = 0.25
const DEEP_FOREST_VFD: float = 0.15
var world_env: WorldEnvironment

func _ready() -> void:
	$Area3D.body_entered.connect(zone_entered)
	$Area3D.body_exited.connect(zone_exited)
	world_env = %dim_world/WorldEnvironment
	if world_env == null: push_error("not found")

func zone_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.name == "player":
		$"../music_player/dark_music".play()
		set_fog(true)

func zone_exited(body: Node3D) -> void:
	if body.is_in_group("player") or body.name == "player":
		$"../music_player/dark_music".stop()
		set_fog(false)

func set_fog(active: bool) -> void:
	if active:
		world_env.environment.volumetric_fog_emission_energy = DEEP_FOREST_VFEE
		world_env.environment.volumetric_fog_density = DEEP_FOREST_VFD
	else:
		world_env.environment.volumetric_fog_emission_energy = ORIGINAL_VFEE
		world_env.environment.volumetric_fog_density = ORIGINAL_VFD
