extends CanvasLayer

signal transitioned
const FADE_TO_BLACK: String = "fade_to_black"
const FADE_TO_NORMAL: String = "fade_to_normal"
var going_to_scene: bool = false
var scene_path: String = ""

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(on_animation_finished)

func transition() -> void:
	$AnimationPlayer.play(FADE_TO_BLACK)

func on_animation_finished(anim_name) -> void:
	if anim_name == FADE_TO_BLACK:
		if going_to_scene:
			going_to_scene = false
			get_tree().change_scene_to_file(scene_path)
		$AnimationPlayer.play(FADE_TO_NORMAL)
	if anim_name == FADE_TO_NORMAL:
		transitioned.emit()
	
func transition_to_scene(path: String) -> void:
	going_to_scene = true
	scene_path = path
	transition()


func restart_scene():
	get_tree().reload_current_scene()
	
