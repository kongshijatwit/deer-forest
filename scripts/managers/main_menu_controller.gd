extends Control


var deer_sfx_lib = ["res://assets/audio/sfx/deer/A_Deer-001.ogg", "res://assets/audio/sfx/deer/A_Deer-002.ogg", "res://assets/audio/sfx/deer/A_Deer-003.ogg",
"res://assets/audio/sfx/deer/A_Deer-004.ogg", "res://assets/audio/sfx/deer/A_Deer-005.ogg"]

# func _ready() -> void:
	# $fade.transitioned.connect(go_to_game)
	# $fade.black_screen.connect(go_to_game)


func _on_play_pressed() -> void:
	$fade.transition_to_scene("res://scenes/game.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	$"../credits_cam".make_current()
	$credits.visible = true
	$title.visible = false
	$button_container.visible = false


func _on_quit_pressed() -> void:
	get_tree().quit()
	# $"../main_menu_cam".make_current()


func go_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_deer_pressed() -> void:
	%Deer/AudioStreamPlayer3D.stream = load(deer_sfx_lib[(randi() % 5)])
	%Deer/AudioStreamPlayer3D.play()
	print("deer pressed")


func _on_credits_back_pressed() -> void:
	$credits.visible = false
	$title.visible = true
	$button_container.visible = true
	$"../main_menu_cam".make_current()
