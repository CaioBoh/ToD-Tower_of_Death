extends State

var attack_finished
@onready var animation_player = $"../../AnimationPlayer"

func enter():
	super.enter()
	attack_finished = false
	owner.set_physics_process(false)
	animation_player.play("RightPush")

func transition():
	if attack_finished:
		get_parent().change_state("Idle")


func _on_animation_player_animation_finished(anim_name):
	attack_finished = true
