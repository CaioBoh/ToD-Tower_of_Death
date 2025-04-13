extends Node2D
@onready var animation_player = $"../AnimationPlayer"

var current_state: State
var previous_state: State

func _ready():
	current_state = get_child(0) as State
	previous_state = current_state
	current_state.enter()
	

func change_state(state):
	owner.set_physics_process(false)
	current_state = find_child(state) as State
	previous_state.exit()
	owner.set_physics_process(false)
	current_state.enter()
	previous_state = current_state
