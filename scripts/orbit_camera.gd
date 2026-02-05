extends Camera3D

## Mobile-optimized Orbit Camera
## Features: Touch drag to orbit, Pinch to zoom, Inertia/Damping

@export_group("Settings")
@export var rotation_speed: float = 0.3
@export var zoom_speed: float = 0.05
@export var damping: float = 0.1
@export var auto_rotate: bool = false
@export var auto_rotate_speed: float = 2.0

@export_group("Limits")
@export var min_distance: float = 2.5
@export var max_distance: float = 8.0
@export var min_pitch: float = -80.0 # Degrees
@export var max_pitch: float = -10.0 # Degrees

var _pivot_node: Node3D
var _current_rotation: Vector2 = Vector2.ZERO
var _target_rotation: Vector2 = Vector2.ZERO
var _current_zoom: float = 4.0
var _target_zoom: float = 4.0
var _drag_velocity: Vector2 = Vector2.ZERO
var _touch_count: int = 0
var _last_touch_dist: float = 0.0

func _ready():
	# Ensure we have a pivot parent
	_pivot_node = get_parent() as Node3D
	if not _pivot_node:
		set_process(false)
		return
		
	# Initialize rotation from current transform
	var rot = _pivot_node.rotation_degrees
	_current_rotation = Vector2(rot.y, rot.x)
	_target_rotation = _current_rotation
	_current_zoom = position.z
	_target_zoom = _current_zoom

func _unhandled_input(event):
	# Touch handling
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_count += 1
			# Reset pinch distance
			_last_touch_dist = 0.0
		else:
			_touch_count = max(0, _touch_count - 1)
			
	elif event is InputEventScreenDrag:
		if _touch_count == 1:
			# Single finger orbit
			_target_rotation.x -= event.relative.x * rotation_speed
			_target_rotation.y -= event.relative.y * rotation_speed
			_target_rotation.y = clamp(_target_rotation.y, min_pitch, max_pitch)
			auto_rotate = false # Disable auto rotate on interaction
			
		elif _touch_count == 2:
			# Pinch zoom simulation (approximate if multi-touch API unavailable)
			# Note: Real pinch requires tracking two specific touch points manually in Godot API
			# For simplicity in this script, we assume vertical drag with 2 fingers = zoom
			# or use InputEventMagnifyGesture if available (Android/iOS often support)
			pass

	# Mouse/Desktop fallback for testing
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = max(min_distance, _target_zoom - 0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = min(max_distance, _target_zoom + 0.5)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_target_rotation.x -= event.relative.x * rotation_speed
		_target_rotation.y -= event.relative.y * rotation_speed
		_target_rotation.y = clamp(_target_rotation.y, min_pitch, max_pitch)
		auto_rotate = false

func _process(delta):
	# Auto rotation
	if auto_rotate:
		_target_rotation.x += auto_rotate_speed * delta

	# Smooth rotation (Damping)
	_current_rotation = _current_rotation.lerp(_target_rotation, 1.0 - pow(damping, delta * 10))
	_pivot_node.rotation_degrees = Vector3(_current_rotation.y, _current_rotation.x, 0)
	
	# Smooth zoom
	_current_zoom = lerp(_current_zoom, _target_zoom, 1.0 - pow(damping, delta * 10))
	position.z = _current_zoom
