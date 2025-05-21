extends Node

@export var change_focus_effect: AudioStreamPlayer
@export var click_effect: AudioStreamPlayer
@export var cancel_effect: AudioStreamPlayer
@export var play_effect: AudioStreamPlayer

func play_change_focus():
	change_focus_effect.play()
	
func play_click():
	click_effect.play()
	
func play_cancel():
	cancel_effect.play()
	
func play_play():
	play_effect.play()
