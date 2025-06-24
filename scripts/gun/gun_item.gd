extends Interactable

@onready var game_manager: Node = $"../../%game_manager"
@export var player_path := "/root/Main/NavigationRegion3D/Player"

var player = null

func _ready():
	# player = get_node(player_path)
	player = get_node("../%player")
	game_manager.reset.connect(reset_gun)

func _on_interacted(_body: Variant) -> void:
	player.gun_taken()
	# queue_free()
	visible = false
	for colliders in get_children():
		if colliders.is_class("CollisionShape3D"):
			colliders.disabled = true

func reset_gun() -> void:
	visible = true
	for colliders in get_children():
		if colliders.is_class("CollisionShape3D"):
			colliders.disabled = false
