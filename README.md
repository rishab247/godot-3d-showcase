# Android 3D Scene - Godot 4.3 Project

High-quality 3D scene optimized for Android devices with Vulkan rendering.

## Project Structure

```
godot-android-3d/
├── project.godot          # Main project configuration
├── export_presets.cfg     # Android export settings
├── icon.svg               # App icon
├── scenes/
│   └── main.tscn          # Main scene with lighting setup
├── assets/
│   ├── textures/          # Texture files
│   ├── models/            # 3D models (.glb, .gltf)
│   └── materials/         # Shared materials
├── autoload/              # Autoloaded scripts
└── export_presets/        # Platform-specific configs
```

## Rendering Configuration

### Renderer
- **Method:** Forward+ (best quality for fixed scenes)
- **Driver:** Vulkan (Android native)
- **Color Space:** sRGB with ACES tonemapping

### Anti-Aliasing Strategy
| Feature | Desktop | Mobile |
|---------|---------|--------|
| MSAA | Off | Off |
| FXAA | On | On |
| TAA | Off | Off |
| Debanding | On | On |

*MSAA disabled for performance; FXAA provides acceptable edge smoothing.*

### Shadow Quality
| Setting | Desktop | Mobile |
|---------|---------|--------|
| Directional Shadow Size | 2048 | 1024 |
| Soft Shadows | Quality 1 | Quality 0 |
| 16-bit Depth | Yes | Yes |
| Shadow Bias | 0.02 | 0.02 |

### Global Illumination
- **Primary:** LightmapGI (baked)
- **Fallback:** Ambient light from sky
- **SDFGI:** Disabled (too expensive for mobile)
- **SSAO:** Disabled (bake AO into textures)
- **SSIL:** Disabled

### Reflection Strategy
- **ReflectionProbe:** Static, box-projected
- **Sky Reflections:** Reduced samples (8 on mobile)
- **Texture Array Reflections:** Disabled on mobile

## Android Export Settings

| Setting | Value |
|---------|-------|
| Min SDK | 24 (Android 7.0) |
| Target SDK | 34 (Android 14) |
| Architecture | arm64-v8a only |
| Gradle Build | Enabled |
| Immersive Mode | Enabled |

## Performance Budget (Mid-range GPU)

Target: **Adreno 640 / Mali-G77** class devices

| Metric | Budget |
|--------|--------|
| Draw Calls | < 200 |
| Triangles | < 500K |
| Texture Memory | < 256 MB |
| Shadow Casters | < 10 |
| Lights | 1 directional + 4 omni |

## Baked Lighting Workflow

1. **Set objects to Static:**
   ```
   MeshInstance3D → GI Mode → Static
   ```

2. **Configure LightmapGI:**
   - Quality: Medium
   - Bounces: 3
   - Directional: Enabled
   - Denoiser: Enabled (strength 0.1)
   - Texel Scale: 1.0

3. **Bake in Editor:**
   - Select LightmapGI node
   - Click "Bake Lightmaps" in toolbar

4. **Mobile Optimization:**
   - Max texture size: 2048
   - Use half-resolution if needed

## Material Guidelines

### PBR Settings for Mobile
```gdscript
# Recommended material setup
material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
material.diffuse_mode = BaseMaterial3D.DIFFUSE_BURLEY
material.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX

# Texture compression
# Use ETC2 for Android (set in import dock)
```

### Texture Import Settings
| Texture Type | Format | Mipmaps |
|--------------|--------|---------|
| Albedo | ETC2 RGBA | Yes |
| Normal | ETC2 RG | Yes |
| ORM | ETC2 RGB | Yes |
| Emission | ETC2 RGB | Yes |

## Build Commands

```bash
# Debug build
godot --headless --export-debug "Android" build/app-debug.apk

# Release build
godot --headless --export-release "Android" build/app-release.apk
```

## Performance Profiling

Enable in-game profiler for testing:
```gdscript
# Add to _ready() in main scene
if OS.is_debug_build():
    get_tree().debug_collisions_hint = false
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
```

## Known Limitations

1. **No real-time GI** - Use baked lightmaps only
2. **No volumetric fog** - Too expensive
3. **Limited dynamic shadows** - 1 directional light max
4. **No SSR** - Use reflection probes instead
5. **No subsurface scattering** - Bake into textures

## Version History

- **1.0.0** - Initial project setup with Android optimization
