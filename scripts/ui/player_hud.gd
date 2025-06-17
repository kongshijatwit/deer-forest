extends Control

@onready var ammo = $BulletCount
@onready var player = $"../.."
@onready var health_bar = $HealthBar
@onready var goal = $"../ObjectivesList/Objective"
@onready var goal2 = $"../ObjectivesList/Objective2"
@onready var timer = $"../ObjectivesList/Timer"
@onready var dialog_blocker: Node = $"../../../%dialog_blocker"
@onready var crosshair = $Crosshair
@onready var game_manager: Node = $"../../../%game_manager"
@onready var between_text = $"../ObjectivesList/Or"
@onready var bed: Node = $"../../../%bed"
@onready var objective_title = $"../ObjectiveTitle"

var timer_start = false
var timer_fin = true
var ammo_hud 
var first_goal = false
var second_goal = false
var third_goal = false
var fourth_goal = false
var fourth_goal_relic = false
var trackable = false
var day_end = false
var new_day = false
var cultist_known = false
var first_day = true

func _ready():
	ammo_hud = str(player.bullet_count) + "/" + str(player.bullet_reserve)
	bed.sleep.connect(finish_day)
	goal.text = "Talk to Stranger"
	

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
		
	if timer.get_time_left() < 1:
		timer_fin = true
		
	if dialog_blocker.villager_talked and !timer_start and !first_goal:
		timer.start()
		timer_start = true
		timer_fin = false
		goal.button_pressed = true
		
	if dialog_blocker.villager_talked and timer_start and timer_fin and !first_goal:
		goal.button_pressed = false
		if cultist_known:
			goal.text = "Talk to Cultist"
		else:
			goal.text = "Talk to other Stranger"
		first_goal = true
		timer_start = false
		timer_fin = true
		
	if dialog_blocker.cultist_talked and !timer_start and !second_goal:
		timer.start()
		timer_start = true
		timer_fin = false
		goal.button_pressed = true
		
	if dialog_blocker.cultist_talked and timer_start and timer_fin and !second_goal:
		goal.button_pressed = false
		goal.text = "Grab your shotgun"
		second_goal = true
		timer_start = false
		timer_fin = true
		
	if player.gun_equipped and !timer_start and !third_goal:
		timer.start()
		timer_start = true
		timer_fin = false
		goal.button_pressed = true
		
	if player.gun_equipped and timer_start and timer_fin and !third_goal:
		goal.button_pressed = false
		trackable = true
		third_goal = true
		timer_start = false
		timer_fin = true
		
	if trackable:
		if !(game_manager.REQUIRED_DEER_AMOUNT == GlobalVariables.deer_killed) and !timer_start and !fourth_goal:
			goal.text = "Hunt %s deer: %s/%s" % [str(game_manager.REQUIRED_DEER_AMOUNT),str(GlobalVariables.deer_killed),str(game_manager.REQUIRED_DEER_AMOUNT)]
			goal2.visible = true
			between_text.visible = true
		elif (game_manager.REQUIRED_DEER_AMOUNT == GlobalVariables.deer_killed) and !timer_start and !fourth_goal:
			goal.text = "Hunt %s deer: %s/%s" % [str(game_manager.REQUIRED_DEER_AMOUNT),str(GlobalVariables.deer_killed),str(game_manager.REQUIRED_DEER_AMOUNT)]
			goal.button_pressed = true
			goal2.disabled = true
			goal2.button_pressed = true
			timer.start()
			timer_start = true
			timer_fin = false
		if GlobalVariables.artifact_piece_collected and !timer_start and !fourth_goal_relic:
			goal2.text = "Collect relic: 1/1"
			goal2.button_pressed = true
			timer.start()
			timer_fin = false
			timer_start = true
		elif !GlobalVariables.artifact_piece_collected and !timer_start and !fourth_goal:
			goal2.text = "Collect relic: 0/1"
		if (game_manager.REQUIRED_DEER_AMOUNT == GlobalVariables.deer_killed) and timer_start and timer_fin and !fourth_goal:
			goal.button_pressed = false
			goal.text = "Go to bed"
			goal2.visible = false
			between_text.visible = false
			timer_start = false
			fourth_goal = true
		if GlobalVariables.artifact_piece_collected and timer_start and timer_fin and !fourth_goal_relic:
			goal2.button_pressed = false
			goal2.text = "Go to bed"
			timer_start = false
			fourth_goal_relic = true
	if day_end and timer_start and timer_fin:
		trackable = false
		timer.start()
		timer_start = true
		timer_fin = false
		first_goal = false
		second_goal = false
		third_goal = false
		fourth_goal = false
		fourth_goal_relic = false
		goal.visible = false
		goal.button_pressed = false
		goal2.visible = false
		goal2.disabled = false
		goal2.button_pressed = false
		between_text.visible = false
		objective_title.visible = false
		day_end = false
		new_day = true
	if new_day and timer_start and timer_fin:
		goal.visible = true
		objective_title.visible = true
		timer_start = false
		new_day = false
		goal.text = "Talk to Villager"
		cultist_known = true	

func finish_day():
	if fourth_goal_relic:
		goal2.button_pressed = true
	if fourth_goal:
		goal.button_pressed = true
	timer.start()
	timer_fin = false
	timer_start = true
	day_end = true
