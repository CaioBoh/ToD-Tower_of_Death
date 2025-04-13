extends Camera2D

@export var dynamic_enabled: bool = false
@export_range(0, 1, 0.01) var dynamic_factor: float = 0.5

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

var target = null
var objects = null
#var max_dist = 2000.0
@onready var max_dist: float = (get_viewport_rect().size / 2.0).distance_to(get_viewport_rect().size)

@onready var normal_zoom = zoom
@onready var normal_position = position
@onready var normal_smoothing_speed = position_smoothing_speed

func _ready():
	set_process(true)
	Global.current_camera = self

# Shake with decreasing intensity while there's time remaining.
func _process(delta):
	if target:
		follow_target(delta)
	elif dynamic_enabled and objects != null:
		# Check if objects are not in tree and return
		var objects_are_in_tree: bool = true
		for x in objects:
			if not x.is_inside_tree():
				objects_are_in_tree = false
				break
		
		if objects_are_in_tree:
			# Offset camera based on the ball position from the center
			var center: Vector2 = get_viewport_rect().size / 2.0
			var average_pos: Vector2 = Vector2.ZERO
			for x in objects:
				average_pos += x.global_position
			average_pos /= objects.size()
			
#			var dist_from_center = center.distance_to(average_pos)
			var dist_from_center = (average_pos - center) / center
			drag_horizontal_offset = dist_from_center.x * dynamic_factor
			drag_vertical_offset = dist_from_center.y * dynamic_factor
			
			# Zoom in or out camera depending on players position
			var max_distance: float = 0.0
			var distance = average_pos.distance_to(Vector2(center.x, get_viewport_rect().size.y))
			
#			print("Distance: ", distance)
#			print("Max dist: ", max_dist)
			zoom = lerp(Vector2(0.975, 0.975), Vector2(1.025, 1.025), 1 - (distance/max_dist))
	else:
		pass
	
	# Only shake when there's shake time remaining.
	if _timer == 0:
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = randf_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = randf_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)
		
func follow_target(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, 12.0*delta)

func reset_camera() -> void:
	global_position = normal_position
	zoom = normal_zoom

func start_tracking(new_target) -> void:
	position_smoothing_enabled = false
	target = new_target
	$Tween.remove_all()
	$Tween.interpolate_property(self, "zoom", zoom, Vector2(0.8, 0.8), 0.8, 
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	$Timer.start(1.5)
	
func stop_tracking() -> void:
	target = null
	position_smoothing_enabled = true
	$Tween.remove_all()
	$Tween.interpolate_property(self, "zoom", zoom, normal_zoom, 1.0, 
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "position", position, normal_position, 0.8, 
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
	if frequency == 0: return
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = randf_range(-1.0, 1.0)
	_previous_y = randf_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)

func _on_Timer_timeout() -> void:
	if target == null or not is_instance_valid(target): return
	$Tween.remove_all()
	$Tween.interpolate_property(self, "zoom", zoom, Vector2(1, 1), 1.5, 
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
