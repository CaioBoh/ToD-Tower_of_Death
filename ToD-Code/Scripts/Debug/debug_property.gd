extends PanelContainer

@export var check_image: TextureRect
var enabled: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		enabled = not enabled
		if check_image.self_modulate.a < 1:
			check_image.self_modulate.a = 0
		else:
			check_image.self_modulate.a = 1
		accept_event() 
