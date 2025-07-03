extends Control

@onready var ammo = $BulletCount
@onready var player = $"../.."
@onready var health_bar = $HealthBar
@onready var dialog_blocker: Node = $"../../../%dialog_blocker"
@onready var crosshair = $Crosshair
@onready var game_manager: Node = $"../../../%game_manager"
@onready var bed: Node = $"../../../%bed"

var ammo_hud 
var first_day = true

func _ready():
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)

func _process(_delta):
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)
	ammo.bbcode_text = ammo_hud
	if player.bullet_count == 0 and player.bullet_reserve == 0:
		ammo.bbcode_text = "[color=#ee0000]%s[/color]" % ammo_hud
	health_bar.value = player.HEALTH
	if player.gun_equipped:
		if first_day:
			$"../GunControlsScreen".visible = true
			$"../GunControlsScreen/AnimationPlayer".play("fadeaway")
			first_day = false
		health_bar.visible = true
		ammo.visible = true
		crosshair.visible = true
	else:
		health_bar.visible = false
		ammo.visible = false
		crosshair.visible = false
		
