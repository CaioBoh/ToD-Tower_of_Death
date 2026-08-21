extends Node

@export var debug_canvas: CanvasLayer
var debug_properties: Array[PanelContainer]
var auto_skip_dialogues: bool = false
var enemy_detection: bool = false
var take_damage: bool = false
var take_knockback: bool = false
var no_clip: bool = false  
var drag_enemies: bool = false
var show_colliders: bool = false

var previous_focused_control: Control = null
var debug_menu_active: bool = false

func _ready() -> void:
	var properties_container = debug_canvas.get_node("CenterContainer").get_node("ScrollContainer").get_node("VBoxContainer")
	for property in properties_container.get_children():
		debug_properties.push_back(property as PanelContainer)

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("Enter Debug Mode"):
		open_debug_menu()

#Takes a screenshot from the active scene
#Warning: Should only be used once per scene and only in editor-mode
#func capture_scene_picture():
	#var custom_viewport: SubViewport = SubViewport.new()
	#var scene_bounds: CollisionShape2D = Global.global_player.get_node("../Scene Bounds") as CollisionShape2D
	#var camera: Camera2D = get_viewport().get_camera_2d()
	#var capture_camera: Camera2D = Camera2D.new()
	#
	#custom_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	#custom_viewport.world_2d = get_viewport().world_2d
	#custom_viewport.size = scene_bounds.shape.size
	#add_child(custom_viewport)
	#capture_camera.global_position = scene_bounds.global_position
	#capture_camera.zoom = Vector2.ONE
	#custom_viewport.add_child(capture_camera)				
	#
	#await RenderingServer.frame_post_draw
#
	#var image = custom_viewport.get_texture().get_image()
	#custom_viewport.queue_free()
	#var save_path: String = "res://Debug/Scene Screenshots/" + Global.global_player.get_node("..").name + "_screenshot.png"
	#image.save_png(save_path)

func open_debug_menu():
	previous_focused_control = get_viewport().gui_get_focus_owner()
	debug_canvas.visible = true
	get_tree().paused = true
	debug_menu_active = true
	
func close_debug_menu():
	debug_canvas.visible = false
	get_tree().paused = false
	debug_menu_active = false
	if is_instance_valid(previous_focused_control):
		previous_focused_control.grab_focus()
		previous_focused_control = null
