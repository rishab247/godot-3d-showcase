# Reflection Setup for Android

## ReflectionProbe Configuration

The scene uses a static `ReflectionProbe` for local reflections, which is the most mobile-friendly approach.

### Why ReflectionProbe?

| Method | Performance | Quality | Mobile Safe |
|--------|-------------|---------|-------------|
| Screen Space Reflections | Medium | Medium | ❌ No |
| ReflectionProbe (Static) | Low | High | ✅ Yes |
| Planar Reflections | High | High | ❌ No |
| Ray Traced | Very High | Best | ❌ No |

### Scene Setup

```
ReflectionProbe
├── Transform: (0, 1, 0)      # Centered on object
├── Size: (12, 8, 12)         # Covers full scene
├── Update Mode: Once         # Static (baked)
├── Box Projection: Enabled   # Accurate local reflections
└── Interior: Disabled        # Uses sky for distant reflections
```

### Key Settings Explained

#### Update Mode: `Once` (Static)
```gdscript
reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE
```
- Captures reflection cubemap on scene load
- Zero runtime cost after initial capture
- Must be re-baked if scene changes

#### Box Projection: `Enabled`
```gdscript
reflection_probe.box_projection = true
```
- Adjusts reflections based on distance to probe bounds
- Prevents reflections "floating" away from surfaces
- Critical for enclosed/studio scenes

#### Interior: `Disabled`
```gdscript
reflection_probe.interior = false
```
- When disabled: sky is visible in reflections
- When enabled: only probe contents (no sky fallback)
- Use `false` for outdoor or studio scenes with sky

#### Ambient Mode: `Custom Color`
```gdscript
reflection_probe.ambient_mode = ReflectionProbe.AMBIENT_COLOR
reflection_probe.ambient_color = Color(0.1, 0.1, 0.15, 1)
reflection_probe.ambient_color_energy = 0.2
```
- Provides consistent ambient in probe area
- Matches scene's dark studio aesthetic

### Placement Guidelines

1. **Center on Subject**
   - Position probe at visual center of reflected object
   - Offset Y slightly above ground plane

2. **Size to Scene**
   - Extend bounds to include all reflecting surfaces
   - Don't make unnecessarily large (reduces quality)

3. **Avoid Overlapping Probes**
   - One probe per scene is ideal for mobile
   - Overlapping causes blending artifacts

### Probe Resolution

The probe resolution is controlled by project settings:

```ini
# project.godot
[rendering]
reflections/sky_reflections/ggx_samples=16
reflections/sky_reflections/ggx_samples.mobile=8
```

Lower sample count on mobile = faster but slightly blurrier reflections.

### Debugging Reflections

To visualize reflection probe coverage:

1. Select the ReflectionProbe in editor
2. Enable `Debug > Show Reflection Probes` in viewport
3. Orange box shows probe influence area

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Black reflections | Probe not baked | Select probe → Bake button |
| Wrong sky in reflections | Interior mode enabled | Set `interior = false` |
| Reflections "pop" | Probe bounds too small | Increase `size` |
| Reflections too bright | Energy too high | Reduce `intensity` |
| No reflections on floor | Floor outside bounds | Extend probe size Y-down |

### Integration with LightmapGI

Both systems work together:
- **LightmapGI**: Provides baked indirect lighting
- **ReflectionProbe**: Provides specular reflections

The probe uses the baked lighting in its capture, creating consistent visual results.
