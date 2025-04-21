extends Area2D
signal hitted

func hurt(_body, _damage):
	print("boss tomou dano")
	hitted.emit()
