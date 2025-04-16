extends CharacterBody2D

@onready var lobby: Node = $".."
@onready var animation: AnimatedSprite2D = $animation
@onready var sword_area_side: Area2D = $SwordSideArea
@onready var sword_area_up: Area2D = $SwordUpArea
@onready var LifeBar: ProgressBar = $LifeBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#@onready var label: Label = $"../HUD/Moedas"
@onready var knockback_vector := Vector2.ZERO
@onready var ghost_spawner = $GhostSpawner
@onready var max_height_stairs: RayCast2D = $MaxHeightStairs
@onready var is_there_stairs: RayCast2D = $IsThereStairs
@onready var is_touching_floor: RayCast2D = $IsTouchingFloor
@onready var actionable_seeker: Area2D = $ActionableSeeker

const SPEED = 250.0
const SLIPPERY = SPEED
const JUMP_VELOCITY = -900.0 #-470
const KNOCKBACK_VELOCITY_MOD = 20
const CROSS_HIT = preload("res://game/particles/scene/cross_hit.tscn")
const DEATH_PARTICLE_ATLAS = preload("res://game/particles/scene/death_particle_atlas.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var cont_moedas: int = 0
var direction: int
var can_dash := false
var move_allowed := true
var sword_pushback_force: float = 30
var is_attacking := false
var is_dash_timer_finished := true
var can_be_hitted := false

func _ready():
	Global.global_player = self
	LifeBar.visible = false
	animation_player.play("RESET")
	Global.is_player_dead = false
	can_be_hitted = true
	Global.death_encounters = 0

func _physics_process(delta):
	LifeBar.value = Global.player_health
	
	if not move_allowed:
		return
	
	if is_on_floor():
		can_dash = true
		
	handle_input(delta)
	handle_animation()
	handle_attack()
	handle_dash()
	handle_stairs_up()
	move_and_slide()

func handle_animation():
	if velocity.x == 0:
		if not is_attacking:
			animation.play("Atlas_idle")
	else:
		if not is_attacking:
			animation.play("Atlas_run")
		else:
			sword_area_side.scale.x = direction
			is_there_stairs.scale.x = direction
		animation.flip_h = direction != 1
		actionable_seeker.position.x = 5.5 + direction * 24.5
		max_height_stairs.position.x = 1.5 + direction * 12.5

func _on_area_2d_body_entered(body):
	if body.has_method("hurt"):
		print("achei")
		body.hurt(self,Global.player_sword_damage)
		var direction_body = global_position.direction_to(body.global_position)
		knockback_vector = Vector2(-direction_body.x * sword_pushback_force, -5)
		var knockback_tween = get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector",Vector2.ZERO,0.2)

func _on_sword_up_area_body_entered(body):
	if body.has_method("hurt"):
		#print("achei")
		body.hurt(self,Global.player_sword_damage)

func handle_attack():
	if not Input.is_action_just_pressed("attack") or is_attacking:
		return
		
	var damage_zone_side = sword_area_side.get_node("CollisionShape2D")
	var damage_zone_up = sword_area_up.get_node("CollisionShape2D")

	is_attacking = true
	if Input.is_action_pressed("up"):
		damage_zone_up.disabled = false
		await get_tree().create_timer(0.3).timeout
		damage_zone_up.disabled = true
		is_attacking = false
	else:
		animation.play("Attack1")
		await get_tree().create_timer(0.2).timeout
		var sound = choose([$SlashSound, $SlashSound2])
		sound.play()
		damage_zone_side.disabled = false
		await animation.animation_finished
		damage_zone_side.disabled = true
		is_attacking = false

func hurt(body,damage):
	if can_be_hitted and not Global.is_player_dead:
		if(Global.player_health > damage):
			can_be_hitted = false
			print("now player is invencible")
			$InvencibleTimer.start()
			Global.player_health -= damage
			LifeBar.visible = true
			var hurt_particle_instance = CROSS_HIT.instantiate()
			hurt_particle_instance.global_position = global_position
			hurt_particle_instance.scale = Vector2(0.7,0.7)
			hurt_particle_instance.rotation_degrees = choose([5,7.5,10,12.5,15,17.5,20,-5,-7.5,-10,-12.5,-15.0,-17.5,-20])
			owner.add_child(hurt_particle_instance)
			animation_player.play("hurt_animation")
			$HurtSound.playing = true
			Global.freeze_time(0.04,0.3)
			knockback_vector = (global_position - body.global_position)
			var knockback_tween:= get_tree().create_tween()
			knockback_tween.tween_property(self,"knockback_vector", Vector2.ZERO,0.25)
			
		else:
			LifeBar.value = 0
			Global.player_health = 0
			## TODO: GAME OVER
			gameOver()


func _on_sword_side_area_area_entered(area):
	if area.has_method("hurt"):
		print("achei")
		area.hurt(self,Global.player_sword_damage)
		var direction_area = global_position.direction_to(area.global_position)
		knockback_vector = (Vector2(direction_area.x, 0)*(-1)) * sword_pushback_force + Vector2(0,-100)
		var knockback_tween = get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector",Vector2.ZERO,0.2)

func _on_sword_up_area_area_entered(area: Area2D) -> void:
	if area.has_method("hurt"):
		print("achei")
		area.hurt(self,Global.player_sword_damage)
		#Sword up dont cause knockback ;D

func collect_coin():
	cont_moedas += 1
	#label.text = "Moedas: %d" % cont_moedas

func gameOver():
	Global.is_player_dead = true
	Global.dead_count+=1
	print(Global.dead_count)
	animation_player.play("death")
	await get_tree().create_timer(0.2).timeout
	set_physics_process(false)
	await animation_player.animation_finished
	SceneTransition.change_scene("res://game/levels/lobby/lobby.tscn")
	Global.player_health = 100
	

func choose(array):
	array.shuffle()
	return array[0]

func handle_dash():
	if Input.is_action_just_pressed("dash") and can_dash and Global.dash_picked and is_dash_timer_finished:
		is_dash_timer_finished = false
		$DashTimer.start()
		ghost_spawner.start_spawn()
		can_dash = false
		knockback_vector = Vector2(direction * 100, 0)
		var knockback_tween = get_tree().create_tween()
		knockback_tween.tween_property(self,"knockback_vector",Vector2.ZERO,0.2)
		$DashSound.play()
		self.set_collision_layer_value(1,false)
		await get_tree().create_timer(0.2).timeout
		ghost_spawner.stop_spawn()
		self.set_collision_layer_value(1,true)

func handle_stairs_up():
	if velocity.x != 0 and is_touching_floor.is_colliding() and is_there_stairs.is_colliding() and not max_height_stairs.is_colliding():
		position.y -=18


func _on_dash_upgrade_dash_picked() -> void:
	move_allowed = false
	animation_player.play("receiving_dash")
	await animation_player.animation_finished
	move_allowed= true

func handle_input(delta: float):
	direction = Input.get_axis("left", "right")
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector * KNOCKBACK_VELOCITY_MOD
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SLIPPERY)
	
	var actionables := actionable_seeker.get_overlapping_areas()
	if Input.is_action_just_pressed("interact") and actionables.size() > 0 and not Global.is_talking:
		actionables[0].action()
		print(Global.dead_count, ", ", Global.death_encounters)
	# Handle jump.
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
func spawn_death_particle():
	var instance = DEATH_PARTICLE_ATLAS.instantiate()
	instance.position = global_position
	instance.emitting = true
	get_owner().add_child(instance)


func _on_dash_timer_timeout():
	is_dash_timer_finished = true


func _on_invencible_timer_timeout():
	print("now player can be hitted!")
	#can_be_hitted = true

func ascend():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 150, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
