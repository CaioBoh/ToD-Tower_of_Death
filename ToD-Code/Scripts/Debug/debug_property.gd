extends PanelContainer

@export var check_image: TextureRect
var enabled: bool = false

signal toggle_property

func _ready():
	check_image.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		enabled = not enabled
		check_image.visible = enabled
		toggle_property.emit()
		accept_event()
