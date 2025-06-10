extends Control

@onready var ammo = $BulletCount
@onready var player = $"../.."
@onready var health_bar = $HealthBar
@onready var goal = $"../PanelContainer/Objective"
@onready var timer = $"../PanelContainer/Timer"
@onready var dialog_blocker: Node = $"../../../%dialog_blocker"
@onready var crosshair = $Crosshair

var timer_start = false
var timer_fin = true
var ammo_hud 
var first_goal = false
var second_goal = false
var third_goal = false

func _ready():
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)
	goal.text = "Talk to visitor"
	

func _process(_delta):
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)
	ammo.bbcode_text = ammo_hud
	if player.bullet_count == 0 and player.bullet_reserve == 0:
		ammo.bbcode_text = "[color=#ee0000]%s[/color]" % ammo_hud
	health_bar.value = player.HEALTH
	if player.gun_equipped:
		health_bar.visible = true
		ammo.visible = true
		crosshair.visible = true
	else:
		health_bar.visible = false
		ammo.visible = false
		crosshair.visible = false
		
	if timer.wait_time < 1:
		timer_fin = true
		
	if dialog_blocker.villager_talked and dialog_blocker.finished_talking and !timer_start and !first_goal:
		timer.start()
		timer_start = true
		timer_fin = false
		goal.button_pressed = true
		
	if dialog_blocker.villager_talked and timer_start and timer_fin and !first_goal and dialog_blocker.finished_talking:
		goal.button_pressed = false
		goal.text = "Talk to other visitor"
		first_goal = true
		timer_start = false
		timer_fin = true
		
	if dialog_blocker.cultist_talked and !timer_start and !second_goal and dialog_blocker.finished_talking:
		timer.start()
		timer_start = true
		timer_fin = false
		goal.button_pressed = true
		
	if dialog_blocker.cultist_talked and timer_start and timer_fin and !second_goal and dialog_blocker.finished_talking:
		goal.button_pressed = false
		goal.text = "Grab your shotgun"
		second_goal = true
		
	
	
