extends Control

func _ready() -> void:
	hide()

func resume():
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
	get_tree().quit()
	
func _process(delta):
	testEsc()
