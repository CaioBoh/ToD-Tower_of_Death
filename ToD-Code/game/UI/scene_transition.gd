extends CanvasLayer

enum menu_state { START_MENU, PAUSE_MENU, PLAYING }

var isTransitioning := false
var current_menu_state := menu_state.START_MENU

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func change_scene(target:String) -> void:
	if isTransitioning:
		return
	isTransitioning = true
	$CanvasLayer/ColorRect.visible = true
	animationPlayer.play("dissolve")
	await animationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	animationPlayer.play_backwards("dissolve")
	await animationPlayer.animation_finished
	$CanvasLayer/ColorRect.visible = false
	isTransitioning = false
	
func resumeDissolve():
	$CanvasLayer/ColorRect.visible = true
	animationPlayer.play()
func pauseDissolve():
	animationPlayer.pause()
func pauseDissolveAndMakeInvisible():
	$CanvasLayer/ColorRect.visible = false
	animationPlayer.pause()
