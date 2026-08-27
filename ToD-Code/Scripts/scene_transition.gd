extends CanvasLayer

enum menu_state { START_MENU, PAUSE_MENU, DEBUG_MENU, OPTIONS, LOADING, PLAYING }

var isTransitioning := false
var is_dissolved: bool = false
var is_dissolving: bool = false
var current_menu_state := menu_state.START_MENU

@onready var dissolve_screen: ColorRect = $DissolveScreenLayer/DissolveScreen
@onready var loading_screen: CanvasLayer = $LoadingScreen
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $LoadingScreen/ProgressBar
@onready var progress_percentage: Label = $LoadingScreen/ProgressPercentage
@onready var press_any_button: Label = $"LoadingScreen/CenterContainer/Press Any Button"
@onready var sceneLastFrame: TextureRect = $SceneLastFrame

@export var MAX_TRANSITION_TIME_ELAPSED: float = 2

func change_scene(target:String, new_menu_state: menu_state, function_to_call: Callable = Callable()) -> int:
	if SceneTransition.isTransitioning:
		return -1
	if function_to_call.is_valid():
		function_to_call.call()
	_change_scene(target, new_menu_state)
	return 0

func _change_scene(target:String, new_menu_state: menu_state) -> void:
	isTransitioning = true
	current_menu_state = menu_state.LOADING
	
	await RenderingServer.frame_post_draw
	var current_frame = get_viewport().get_texture().get_image()
	var generated_texture = ImageTexture.create_from_image(current_frame)
	sceneLastFrame.texture = generated_texture
	sceneLastFrame.visible = true
	
	get_tree().current_scene.queue_free()
	
	animationPlayer.play("dissolve")
	
	ResourceLoader.load_threaded_request(target)
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target, progress)
	var start_time: float = Time.get_ticks_msec()
	
	while status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		if(Time.get_ticks_msec() - start_time > MAX_TRANSITION_TIME_ELAPSED * 1000 and is_dissolved and not is_dissolving):
			animationPlayer.play("reverse_dissolve")
			loading_screen.visible = true
		progress_bar.value = progress[0] * 100
		progress_percentage.text = str(int(progress[0] * 100)) + "%"
		status = ResourceLoader.load_threaded_get_status(target, progress)
		await get_tree().process_frame
		
	progress_bar.value = 100
	progress_percentage.text = "100%"
	
	if (is_dissolving and is_dissolved) or not is_dissolved:
		animationPlayer.play("dissolve")
		await animationPlayer.animation_finished
	
	loading_screen.visible = false
	press_any_button.visible = false
	
	var new_scene_resource = ResourceLoader.load_threaded_get(target)
	var new_scene_instantiated: Node = new_scene_resource.instantiate()
	get_tree().root.add_child(new_scene_instantiated)
	get_tree().current_scene = new_scene_instantiated
	Global.current_level_path = target
	
	animationPlayer.play("reverse_dissolve")
	await animationPlayer.animation_finished
	
	isTransitioning = false
	current_menu_state = new_menu_state
	
func resumeDissolve():
	animationPlayer.play()
	
func pauseDissolve():
	animationPlayer.pause()
	
func pauseDissolveAndMakeInvisible():
	animationPlayer.pause()
	
func started_dissolve():
	is_dissolving = true	

func finished_dissolve():
	is_dissolved = not is_dissolved
	if is_dissolved: sceneLastFrame.visible = false
		
	is_dissolving = false
	
