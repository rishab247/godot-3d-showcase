extends Node
## Runtime error handler with clipboard capture for Android.
## Add to autoload as "ErrorHandler" - must be FIRST in autoload order.

const RENDERER_INFO_KEYS := [
	"rendering/driver/driver_name",
	"rendering/rendering_device/device_name",
	"rendering/rendering_device/device_type",
]

var _error_log: Array[String] = []
var _device_info: String = ""
var _has_critical_error: bool = false
var _clipboard_copied: bool = false


func _init() -> void:
	# Capture errors as early as possible
	_collect_device_info()
	_setup_error_handlers()


func _ready() -> void:
	# Log successful startup
	_log("=== APP STARTED ===")
	_log("Time: " + Time.get_datetime_string_from_system())
	_log(_device_info)
	_log("===================")
	
	# Test Vulkan/renderer status
	_check_renderer_status()


func _setup_error_handlers() -> void:
	# Connect to script error signal (Godot 4.x)
	if Engine.has_signal("script_error"):
		Engine.connect("script_error", _on_script_error)
	
	# Set custom error handler
	# Note: In Godot 4, we use push_error interception via _notification


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CRASH:
			_on_crash("NOTIFICATION_CRASH received")
		NOTIFICATION_WM_CLOSE_REQUEST:
			_log("App close requested")
		NOTIFICATION_APPLICATION_PAUSED:
			_log("App paused")
		NOTIFICATION_APPLICATION_RESUMED:
			_log("App resumed")


func _collect_device_info() -> String:
	var info := PackedStringArray()
	
	info.append("=== DEVICE INFO ===")
	info.append("OS: " + OS.get_name() + " " + OS.get_version())
	info.append("Model: " + OS.get_model_name())
	info.append("Arch: " + Engine.get_architecture_name())
	info.append("Godot: " + Engine.get_version_info().string)
	info.append("Locale: " + OS.get_locale())
	
	# Rendering info (available after renderer init)
	if RenderingServer.get_video_adapter_name():
		info.append("GPU: " + RenderingServer.get_video_adapter_name())
		info.append("Vendor: " + RenderingServer.get_video_adapter_vendor())
		info.append("Driver: " + RenderingServer.get_video_adapter_api_version())
	
	# Display info
	var screen_size := DisplayServer.screen_get_size()
	info.append("Screen: %dx%d" % [screen_size.x, screen_size.y])
	info.append("DPI: " + str(DisplayServer.screen_get_dpi()))
	
	_device_info = "\n".join(info)
	return _device_info


func _check_renderer_status() -> void:
	var adapter := RenderingServer.get_video_adapter_name()
	var api := RenderingServer.get_video_adapter_api_version()
	
	_log("Renderer: " + adapter)
	_log("API: " + api)
	
	# Check for Vulkan vs OpenGL fallback
	if "Vulkan" in api:
		_log("✓ Vulkan active")
	elif "OpenGL" in api or "GLES" in api:
		_log("⚠ Fell back to OpenGL ES (Vulkan unavailable)")
	else:
		_log("⚠ Unknown renderer: " + api)
	
	# Check for Mali GPU specific issues
	if "Mali" in adapter:
		_log("✓ Mali GPU detected: " + adapter)
		if "G52" in adapter:
			_log("✓ Mali-G52 confirmed")


func _on_script_error(script_path: String, line: int, column: int, error: String, stack: String) -> void:
	var msg := "SCRIPT ERROR in %s:%d:%d\n%s\n%s" % [script_path, line, column, error, stack]
	_log_error(msg)


func _on_crash(reason: String) -> void:
	_has_critical_error = true
	_log_error("CRASH: " + reason)
	_copy_to_clipboard_immediate()


func _log(message: String) -> void:
	var timestamp := Time.get_time_string_from_system()
	var entry := "[%s] %s" % [timestamp, message]
	_error_log.append(entry)
	print(entry)  # Also to logcat


func _log_error(message: String) -> void:
	var timestamp := Time.get_time_string_from_system()
	var entry := "[%s] ERROR: %s" % [timestamp, message]
	_error_log.append(entry)
	push_error(entry)  # To logcat with ERROR level
	printerr(entry)
	
	# Copy to clipboard on any error
	_copy_to_clipboard_immediate()


func _copy_to_clipboard_immediate() -> void:
	if _clipboard_copied:
		return  # Only copy once to avoid overwriting
	
	var report := _generate_error_report()
	
	# Try multiple clipboard methods for reliability
	if OS.has_feature("android"):
		_copy_to_android_clipboard(report)
	else:
		DisplayServer.clipboard_set(report)
	
	_clipboard_copied = true
	_log("Error report copied to clipboard (%d chars)" % report.length())


func _copy_to_android_clipboard(text: String) -> void:
	# Primary method: DisplayServer
	DisplayServer.clipboard_set(text)
	
	# Fallback: Direct JNI call if available
	if Engine.has_singleton("ClipboardManager"):
		var clipboard = Engine.get_singleton("ClipboardManager")
		if clipboard and clipboard.has_method("set_text"):
			clipboard.set_text(text)


func _generate_error_report() -> String:
	var report := PackedStringArray()
	
	report.append("╔══════════════════════════════════════╗")
	report.append("║   GODOT ANDROID ERROR REPORT         ║")
	report.append("╚══════════════════════════════════════╝")
	report.append("")
	report.append(_device_info)
	report.append("")
	report.append("=== ERROR LOG ===")
	
	for entry in _error_log:
		report.append(entry)
	
	report.append("")
	report.append("=== END REPORT ===")
	report.append("Generated: " + Time.get_datetime_string_from_system())
	
	return "\n".join(report)


## Call this to manually trigger error report (e.g., from UI button)
func get_error_report() -> String:
	return _generate_error_report()


## Call this to manually copy current log to clipboard
func copy_log_to_clipboard() -> void:
	_clipboard_copied = false  # Allow re-copy
	_copy_to_clipboard_immediate()


## Log a custom error from anywhere in the app
func log_custom_error(category: String, message: String, stack: String = "") -> void:
	var full := "[%s] %s" % [category, message]
	if stack:
		full += "\nStack: " + stack
	_log_error(full)


## Check if any errors occurred
func has_errors() -> bool:
	for entry in _error_log:
		if "ERROR" in entry:
			return true
	return false
