extends CanvasLayer

signal transitioned
const FADE_TO_BLACK: String = "fade_to_black"
const FADE_TO_NORMAL: String = "fade_to_normal"

func _ready():
	$AnimationPlayer.animation_finished.connect(on_animation_finished)
	transition()

func transition():
	$AnimationPlayer.play(FADE_TO_BLACK)

func on_animation_finished(anim_name):
	if anim_name == FADE_TO_BLACK:
		$AnimationPlayer.play(FADE_TO_NORMAL)
	if anim_name == FADE_TO_NORMAL:
		print("emit")
		transitioned.emit()
	

