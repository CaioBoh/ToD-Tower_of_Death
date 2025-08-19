extends State
@onready var animation_player = $"../../AnimationPlayer"
@onready var attack_timer = $"../../AttackTimer"

var is_attacking = false
var attacks = ["SincPunch", "RightPunch", "LeftPunch", "LeftPush", "RightPush", "PressAttack", "RightUga", "LeftUga"];
var attack_chance = [(100.0 / attacks.size()),(100.0 / attacks.size()),(100.0 / attacks.size()),(100.0 / attacks.size()),(100.0 / attacks.size()),(100.0 / attacks.size()),(100.0 / attacks.size()),(100.0 / attacks.size())]

func enter():
	randomize()
	super.enter()
	owner.set_physics_process(true)
	attack_timer.start()
	is_attacking = false

func _on_attack_timer_timeout():
	is_attacking = true
	attack_timer.wait_time = randf_range(3, 5)
	print("it will attack! and its new time for attack is ", attack_timer.wait_time)
	
func transition():
	if is_attacking:
		var choice = randf_range(1,100)
		var chance_changed = false
		var current_chance = 0
		var attack = "SincPunch"
		var chance_removed
		print("attack chance size : ", attack_chance.size())
		#check for which attack is and remove its chance
		for c in range(attack_chance.size()):
			current_chance+=attack_chance[c]
			if choice < current_chance and not chance_changed:
				attack = attacks[c]
				chance_removed = attack_chance[c]/3
				attack_chance[c]-=attack_chance[c]/3
				chance_changed = true
				print(attacks[c]," : ", attack_chance[c])
		print("Current total chance: ", current_chance)
		#add to the other attack the chance that was removed, and remove the integer error.
		for i in range(attack_chance.size()):
			attack_chance[i] -= (current_chance-100)/attack_chance.size()
			if attacks[i] != attack and chance_removed:
				print(attacks[i]," : ", attack_chance[i])
				attack_chance[i]+=chance_removed/attack_chance.size()
		get_parent().change_state(attack)
		print("current attack is : " + attack)
		

func exit():
	super.exit()
