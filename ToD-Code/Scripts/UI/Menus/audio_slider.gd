extends Control

@export var audio_label: Label
@export var value_label: Label
@export var audio_slider: Slider
@export_enum("Master", "Music", "Sound Effects") var bus_name: String

var bus_index := 0

func _ready() -> void:
	match bus_name:
		"Master":
			audio_label.text = "Tudo"
		"Music":
			audio_label.text = "Música"
		"Sound Effects":
			audio_label.text = "Efeitos"
	bus_index = AudioServer.get_bus_index(bus_name)
	# Pega volume em dB e converte pra linear (0.0 - 1.0)
	var db := AudioServer.get_bus_volume_db(bus_index)
	audio_slider.value = db_to_linear(db)

	value_label.text = str(int(audio_slider.value * 100)) + "%"


func _on_value_slider_value_changed(value: float) -> void:
	# Converte linear (0.0 - 1.0) pra dB
	var db := linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, db)

	value_label.text = str(int(audio_slider.value * 100)) + "%"
	
