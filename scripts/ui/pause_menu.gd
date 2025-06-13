extends Control

@onready var StartMenu = $PanelContainer/StartMenu
@onready var QuitMenu = $PanelContainer/QuitMenu
@onready var SoundMenu = $PanelContainer/SoundMenu
@onready var ControlsMenu = $PanelContainer/ControlsMenu
@onready var returnbutt = $ReturnControls
@onready var msg = $MenuMessage
@onready var ctrlmsg = $ControlsTitle

func _ready() -> void:
	hide()

func resume():
	msg.text = "Paused"
	QuitMenu.visible = false
	SoundMenu.visible = false
	ControlsMenu.visible = false
	returnbutt.visible = false
	ctrlmsg.visible = false
	StartMenu.visible = true
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func pause():
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func testEsc():
	if Input.is_action_just_pressed("menu") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("menu") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	StartMenu.visible = false
	QuitMenu.visible = true
	msg.text = "Are you sure you want to quit?"
	
func _process(_delta):
	testEsc()

func _on_quit_real_pressed() -> void:
	get_tree().quit()
	
func _on_cancel_pressed() -> void:
	QuitMenu.visible = false
	StartMenu.visible = true
	msg.text = "Paused"
	
func _on_sound_settings_pressed() -> void:
	StartMenu.visible = false
	SoundMenu.visible = true
	msg.text = "Sound Settings"
	
func _on_confirm_pressed() -> void:
	SoundMenu.visible = false
	StartMenu.visible = true
	msg.text = "Paused"
	
func _on_controls_pressed() -> void:
	StartMenu.visible = false
	ControlsMenu.visible = true
	msg.text = ""
	ctrlmsg.visible = true
	returnbutt.visible = true
	

func _on_return_controls_pressed() -> void:
	ControlsMenu.visible = false
	StartMenu.visible = true
	ctrlmsg.visible = false
	msg.text = "Paused"
	returnbutt.visible = false
	
