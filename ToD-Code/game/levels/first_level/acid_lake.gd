extends Area2D
@onready var marker_2d: Marker2D = $Marker2D
@export var acid_damage: int = 20




func _on_body_entered(body: Node2D) -> void:
	body.hurt(self,acid_damage);
	body.knockback_vector = Vector2.ZERO
	await get_tree().create_timer(.1).timeout
	print(Global.player_health)
	if body == Global.global_player and Global.player_health > 0 :
		body.global_position = marker_2d.global_position

	
	
	
