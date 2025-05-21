extends CanvasLayer

enum menu_state { START_MENU, PAUSE_MENU, OPTIONS, LOADING, PLAYING }

var isTransitioning := false
var current_menu_state := menu_state.START_MENU

@onready var dissolve_screen: ColorRect = $DissolveScreenLayer/DissolveScreen
@onready var loading_screen: CanvasLayer = $LoadingScreen
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $LoadingScreen/ProgressBar
@onready var progress_percentage: Label = $LoadingScreen/ProgressPercentage

func _process(delta: float) -> void:
	print(isTransitioning)

func change_scene(target:String, new_menu_state: menu_state) -> void:
	if isTransitioning:
		return
		
	isTransitioning = true
	current_menu_state = menu_state.LOADING
	
	animationPlayer.play("dissolve")
	await animationPlayer.animation_finished
	
	get_tree().current_scene.queue_free()
	
	animationPlayer.play_backwards("dissolve")
	loading_screen.visible = true
	
	ResourceLoader.load_threaded_request(target)
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target, progress)
	while status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		progress_bar.value = progress[0] * 100
		progress_percentage.text = str(int(progress[0] * 100)) + "%"
		status = ResourceLoader.load_threaded_get_status(target, progress)
		await get_tree().process_frame
		
	progress_bar.value = 100
	progress_percentage.text = "100%"
		
	while not Input.is_anything_pressed():
		await get_tree().process_frame
	
	animationPlayer.play("dissolve")
	await animationPlayer.animation_finished
	
	loading_screen.visible = false
	
	var new_scene_resource = ResourceLoader.load_threaded_get(target)
	var new_scene_instantiated = new_scene_resource.instantiate()
	get_tree().root.add_child(new_scene_instantiated)
	get_tree().current_scene = new_scene_instantiated
	
	animationPlayer.play_backwards("dissolve")
	await animationPlayer.animation_finished
	
	isTransitioning = false
	current_menu_state = new_menu_state
	
func resumeDissolve():
	animationPlayer.play()
func pauseDissolve():
	animationPlayer.pause()
func pauseDissolveAndMakeInvisible():
	animationPlayer.pause()
