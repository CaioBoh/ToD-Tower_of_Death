extends Node
class_name SaveLoad

static func save_game_data():
	var game_data := GameData.new()
	
	game_data.key_picked = Global.key_picked
	game_data.dash_picked = Global.dash_picked
	game_data.death_count = Global.dead_count
	game_data.death_encounters = Global.death_encounters
	game_data.double_jump_picked = Global.double_jump_picked
	game_data.player_health = Global.player_health
	game_data.player_position = Global.global_player.global_position
	game_data.collectibles_collected = Global.collectibles_collected
	game_data.current_level_path = Global.current_level_path
	
	ResourceSaver.save(game_data, "user://game_data.tres")
	
static func load_game_data():
	if not ResourceLoader.exists("user://game_data.tres", "GameData"):
		Global.key_picked = false
		Global.dash_picked = false
		Global.dead_count = 0
		Global.death_encounters = 0
		Global.double_jump_picked = false
		Global.player_health = 100
		Global.initial_player_position = Vector2(393, 33)
		Global.current_level_path = "res://Scenes/Levels/lobby.tscn"
		for i in range(Global.amount_of_collectibles):
			Global.collectibles_collected.append(false)
		Global.collectibles_found = 0
		return
		
	var game_data: GameData = load("user://game_data.tres")
	
	Global.key_picked = game_data.key_picked
	Global.dash_picked = game_data.dash_picked
	Global.dead_count = game_data.death_count
	Global.death_encounters = game_data.death_encounters
	Global.double_jump_picked = game_data.double_jump_picked
	Global.player_health = game_data.player_health
	Global.initial_player_position = game_data.player_position
	Global.collectibles_collected = game_data.collectibles_collected
	Global.current_level_path = game_data.current_level_path
	
	Global.collectibles_found = 0
	for i in range(Global.collectibles_collected.size()):
		if Global.collectibles_collected[i]:
			Global.collectibles_found += 1
			
static func delete_game_data():
	if ResourceLoader.exists("user://game_data.tres", "GameData"):
		DirAccess.remove_absolute("user://game_data.tres");
		
static func save_sound_data():
	var sound_data := SoundData.new()
	for audio_slider in Options.audios_sliders:
		match audio_slider.bus_name:
			"Master":
				sound_data.master_volume = audio_slider.audio_slider.value
			"Music":
				sound_data.music_volume = audio_slider.audio_slider.value
			"Sound Effects":
				sound_data.sound_effects_volume = audio_slider.audio_slider.value
	
	ResourceSaver.save(sound_data, "user://sound_data.tres")
	
static func load_sound_data(audio_slider: AudioSlider):
	if not ResourceLoader.exists("user://sound_data.tres", "SoundData"):
		return
	
	var sound_data: SoundData = load("user://sound_data.tres")
	
	match audio_slider.bus_name:
		"Master":
			audio_slider.audio_slider.value = sound_data.master_volume
		"Music":
			audio_slider.audio_slider.value = sound_data.music_volume
		"Sound Effects":
			audio_slider.audio_slider.value = sound_data.sound_effects_volume
