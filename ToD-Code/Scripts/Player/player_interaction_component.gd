extends Node
class_name player_interaction_component

@export var actionable_seeker_area: Area2D
@export var just_stopped_talking_timer: Timer

func flip_seeker(physics_component : player_physics_component):
	if(physics_component.looking_direction * actionable_seeker_area.position.x < 0):
		actionable_seeker_area.position.x = -actionable_seeker_area.position.x
	
func talk() -> bool:
	if not Global.input_allowed or SceneTransition.isTransitioning or Global.is_talking:
		return false
		
	var talked = false
	var actionables := actionable_seeker_area.get_overlapping_areas()
	var can_someone_talk : bool = actionables.size() > 0 and actionables[0].talkable
	if Input.is_action_just_pressed("interact") and can_someone_talk:
		actionables[0].action()
		talked = true
	return talked
	
func _on_just_stopped_talking_timeout():
	Global.is_talking = false
