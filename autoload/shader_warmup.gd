extends Node
## Shader warmup and validation for Android.
## Precompiles shaders to avoid runtime stutter.

signal warmup_complete
signal shader_error(shader_name: String, error: String)

var _shaders_to_compile: Array[String] = []
var _compile_errors: Array[String] = []


func _ready() -> void:
	# Run shader warmup on startup
	call_deferred("_warmup_shaders")


func _warmup_shaders() -> void:
	_log("Starting shader warmup...")
	
	# Force shader compilation by rendering off-screen
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	
	# Create test geometry with common materials
	var test_meshes := _create_test_meshes()
	for mesh in test_meshes:
		viewport.add_child(mesh)
	
	# Add camera
	var cam := Camera3D.new()
	cam.position = Vector3(0, 0, 5)
	viewport.add_child(cam)
	
	# Add light
	var light := DirectionalLight3D.new()
	viewport.add_child(light)
	
	# Wait for render
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Cleanup
	viewport.queue_free()
	
	_log("Shader warmup complete")
	warmup_complete.emit()


func _create_test_meshes() -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	
	# Standard PBR material
	var pbr_mesh := MeshInstance3D.new()
	pbr_mesh.mesh = SphereMesh.new()
	var pbr_mat := StandardMaterial3D.new()
	pbr_mat.metallic = 0.5
	pbr_mat.roughness = 0.5
	pbr_mesh.material_override = pbr_mat
	meshes.append(pbr_mesh)
	
	# High metallic
	var metal_mesh := MeshInstance3D.new()
	metal_mesh.mesh = SphereMesh.new()
	var metal_mat := StandardMaterial3D.new()
	metal_mat.metallic = 1.0
	metal_mat.roughness = 0.1
	metal_mesh.material_override = metal_mat
	metal_mesh.position.x = 2
	meshes.append(metal_mesh)
	
	# Emissive
	var emit_mesh := MeshInstance3D.new()
	emit_mesh.mesh = SphereMesh.new()
	var emit_mat := StandardMaterial3D.new()
	emit_mat.emission_enabled = true
	emit_mat.emission = Color(1, 0.5, 0)
	emit_mesh.material_override = emit_mat
	emit_mesh.position.x = -2
	meshes.append(emit_mesh)
	
	return meshes


func _log(msg: String) -> void:
	print("[ShaderWarmup] " + msg)
	if Engine.has_singleton("ErrorHandler"):
		pass  # ErrorHandler will capture prints
