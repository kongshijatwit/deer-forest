extends Interactable

@export var player_path := "/root/Main/NavigationRegion3D/Player"

var player = null

func _ready():
	player = get_node(player_path)

func _on_interacted(body: Variant) -> void:
	player.gun_taken()
	queue_free()
