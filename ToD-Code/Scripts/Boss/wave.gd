extends Area2D

var speed
var acceleration

func _physics_process(delta):
	if acceleration:
		speed += acceleration * delta
	position.x += speed * delta


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	if body.has_method("hurt") and body.get_collision_layer_value(1):
		body.hurt(self,10)
