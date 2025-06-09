extends Control

@onready var ammo = $BulletCount
@onready var player = $"../.."
@onready var health_bar = $HealthBar

var timer_start = false
var timer_fin = true
var ammo_hud 

func _ready():
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)

func _process(delta):
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)
	ammo.bbcode_text = ammo_hud
	if player.bullet_count == 0 and player.bullet_reserve == 0:
		ammo.bbcode_text = "[color=#ee0000]%s[/color]" % ammo_hud
	health_bar.value = player.HEALTH
	if player.gun_equipped:
		health_bar.visible = true
		ammo.visible = true
	else:
		health_bar.visible = false
		ammo.visible = false
	
