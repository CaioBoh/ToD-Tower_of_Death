extends CharacterBody2D
class_name player_script

@export var animation_component : player_animation_component
@export var physics_component : player_physics_component
@export var interaction_component : player_interaction_component
@export var combat_component : player_combat_component
@export var dash_component : player_dash_component

@export var max_player_health: int = 100
var player_health: int = max_player_health

signal health_changed

func _ready():
	Global.global_player = self
	animation_component.animation_player.play("RESET")

func _physics_process(delta):
	handle_input(delta)
	handle_animation()
	handle_attack()
	handle_dash()
	flip()
	move_and_slide()
	
func handle_input(delta):
	interaction_component.talk()
	physics_component.jump(delta, is_on_floor(), self)
	physics_component.move(self)
	
func handle_animation():
	animation_component.handle_animation(physics_component, combat_component, velocity)
	
func handle_attack():
	combat_component.handle_attack(physics_component, animation_component)
	
func handle_dash():
	dash_component.handle_dash(physics_component, is_on_floor())
	
func flip():
	animation_component.flip_sprite(physics_component)
	physics_component.flip_areas()
	interaction_component.flip_seeker(physics_component)

func hurt(body,damage):
	player_health -= combat_component.hurt(self, body, damage, animation_component, physics_component)
	
	if(player_health == 0):
		death()
	else:
		health_changed.emit()

func death():
	Global.game_over()
	animation_component.animation_player.play("death")
	
	await get_tree().create_timer(0.2).timeout
	set_physics_process(false)
	await animation_component.animation_player.animation_finished
	
	SceneTransition.change_scene("res://Scenes/Levels/lobby.tscn", SceneTransition.menu_state.PLAYING)
	player_health = 100
	Global.is_player_dead = false
