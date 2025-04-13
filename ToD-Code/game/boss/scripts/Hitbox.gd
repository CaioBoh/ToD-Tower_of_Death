extends Area2D
signal hitted

func hurt(body, damage):
	print("boss tomou dano")
	hitted.emit()
