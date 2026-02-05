extends Node3D
class_name ShowcaseController
## Controls the showcase scene: handles material swapping, lighting presets, etc.

signal material_changed(material_name: String)
signal preset_changed(preset_name: String)

@export var showcase_object: MeshInstance3D
@export var key_light: DirectionalLight3D
@export var fill_light: DirectionalLight3D
@export var environment: WorldEnvironment

# Material presets
enum MaterialPreset {
	CHROME,
	GOLD,
	COPPER,
	BRUSHED_METAL,
	PLASTIC_WHITE,
	PLASTIC_RED,
	CERAMIC
}

# Lighting presets
enum LightingPreset {
	STUDIO,
	WARM,
	COOL,
	DRAMATIC,
	SOFT
}

var _current_material: MaterialPreset = MaterialPreset.CHROME
var _current_lighting: LightingPreset = LightingPreset.STUDIO


func _ready() -> void:
	# Apply default presets
	apply_material_preset(MaterialPreset.CHROME)
	apply_lighting_preset(LightingPreset.STUDIO)


func apply_material_preset(preset: MaterialPreset) -> void:
	if not showcase_object:
		return
	
	var mat := showcase_object.get_surface_override_material(0) as StandardMaterial3D
	if not mat:
		mat = StandardMaterial3D.new()
		showcase_object.set_surface_override_material(0, mat)
	
	match preset:
		MaterialPreset.CHROME:
			mat.albedo_color = Color(0.95, 0.95, 0.97, 1)
			mat.metallic = 1.0
			mat.roughness = 0.05
			mat.rim_enabled = true
			mat.rim = 0.1
		
		MaterialPreset.GOLD:
			mat.albedo_color = Color(1.0, 0.84, 0.0, 1)
			mat.metallic = 1.0
			mat.roughness = 0.2
			mat.rim_enabled = true
			mat.rim = 0.15
		
		MaterialPreset.COPPER:
			mat.albedo_color = Color(0.72, 0.45, 0.2, 1)
			mat.metallic = 1.0
			mat.roughness = 0.25
			mat.rim_enabled = true
			mat.rim = 0.1
		
		MaterialPreset.BRUSHED_METAL:
			mat.albedo_color = Color(0.6, 0.62, 0.65, 1)
			mat.metallic = 0.9
			mat.roughness = 0.4
			mat.rim_enabled = false
		
		MaterialPreset.PLASTIC_WHITE:
			mat.albedo_color = Color(0.95, 0.95, 0.95, 1)
			mat.metallic = 0.0
			mat.roughness = 0.3
			mat.rim_enabled = false
		
		MaterialPreset.PLASTIC_RED:
			mat.albedo_color = Color(0.8, 0.1, 0.1, 1)
			mat.metallic = 0.0
			mat.roughness = 0.35
			mat.rim_enabled = false
		
		MaterialPreset.CERAMIC:
			mat.albedo_color = Color(0.98, 0.98, 0.96, 1)
			mat.metallic = 0.0
			mat.roughness = 0.15
			mat.rim_enabled = true
			mat.rim = 0.2
	
	_current_material = preset
	material_changed.emit(MaterialPreset.keys()[preset])


func apply_lighting_preset(preset: LightingPreset) -> void:
	if not key_light or not fill_light:
		return
	
	match preset:
		LightingPreset.STUDIO:
			key_light.light_color = Color(1, 0.95, 0.9, 1)
			key_light.light_energy = 1.5
			fill_light.light_color = Color(0.7, 0.8, 1, 1)
			fill_light.light_energy = 0.4
		
		LightingPreset.WARM:
			key_light.light_color = Color(1, 0.85, 0.7, 1)
			key_light.light_energy = 1.8
			fill_light.light_color = Color(1, 0.9, 0.8, 1)
			fill_light.light_energy = 0.3
		
		LightingPreset.COOL:
			key_light.light_color = Color(0.85, 0.9, 1, 1)
			key_light.light_energy = 1.4
			fill_light.light_color = Color(0.6, 0.7, 0.9, 1)
			fill_light.light_energy = 0.5
		
		LightingPreset.DRAMATIC:
			key_light.light_color = Color(1, 0.92, 0.85, 1)
			key_light.light_energy = 2.2
			fill_light.light_color = Color(0.3, 0.4, 0.6, 1)
			fill_light.light_energy = 0.15
		
		LightingPreset.SOFT:
			key_light.light_color = Color(1, 0.98, 0.95, 1)
			key_light.light_energy = 1.0
			fill_light.light_color = Color(0.9, 0.92, 1, 1)
			fill_light.light_energy = 0.6
	
	_current_lighting = preset
	preset_changed.emit(LightingPreset.keys()[preset])


func next_material() -> void:
	var next := (_current_material + 1) % MaterialPreset.size()
	apply_material_preset(next as MaterialPreset)


func next_lighting() -> void:
	var next := (_current_lighting + 1) % LightingPreset.size()
	apply_lighting_preset(next as LightingPreset)
