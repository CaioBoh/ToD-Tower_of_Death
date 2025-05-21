extends Area2D

@onready var marker_2d: Marker2D = $Marker2D
@export var acid_damage: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body == Global.global_player:
		body.hurt(self,acid_damage);
		body.knockback_vector = Vector2.ZERO
		await get_tree().create_timer(0.1).timeout
		if Global.player_health > 0 :
			body.global_position = marker_2d.global_position
	else:
		body.hurt(self, body.health)

	
	
	
