# PBR Material Configuration for Android

## Material: `StandardMaterial3D_pbr_showcase`

This material is optimized for showcasing reflective objects on Android GPUs.

### Core PBR Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `shading_mode` | Per-Pixel (1) | Proper specular highlights |
| `diffuse_mode` | Burley (1) | Physically accurate diffuse |
| `specular_mode` | Schlick-GGX (1) | Realistic metal reflections |

### Surface Properties

| Property | Chrome | Gold | Copper | Ceramic |
|----------|--------|------|--------|---------|
| Albedo | #F2F0E0 | #FFD700 | #B87333 | #FAFAF5 |
| Metallic | 0.9 | 1.0 | 1.0 | 0.0 |
| Roughness | 0.15 | 0.2 | 0.25 | 0.15 |
| Rim | 0.1 | 0.15 | 0.1 | 0.2 |

### Texture Slots (When Using Textures)

```gdscript
# Recommended texture setup
material.albedo_texture = preload("res://assets/textures/albedo.png")
material.normal_texture = preload("res://assets/textures/normal.png")
material.normal_enabled = true
material.normal_scale = 1.0

# ORM texture (Occlusion/Roughness/Metallic in RGB)
material.orm_texture = preload("res://assets/textures/orm.png")
material.ao_enabled = true
material.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
```

### Import Settings for Android

All textures should use these import settings:

| Setting | Value |
|---------|-------|
| Compress/Mode | VRAM Compressed |
| Compress/Lossy Quality | 0.7 |
| Compress/Normal Map | Enabled (for normal maps) |
| Mipmaps/Generate | Enabled |
| Mipmaps/Limit | 0 (auto) |
| Process/Size Limit | 2048 |

### Mobile-Specific Optimizations

1. **Avoid Triplanar Mapping** - Uses extra texture samples
2. **Disable Detail Textures** - Extra overhead on mobile
3. **Use ORM Packing** - Combine AO, Roughness, Metallic into one texture
4. **Limit Texture Count** - Max 4 textures per material
5. **Disable Subsurface Scattering** - Too expensive
6. **Disable Refraction** - Requires extra passes

### Rim Lighting

Rim lighting adds edge highlights without extra lights:

```gdscript
material.rim_enabled = true
material.rim = 0.1        # Subtle edge glow
material.rim_tint = 0.3   # Blend with surface color
```

This is cheaper than adding fill lights and works well for product visualization.

### Clearcoat (Optional)

For car paint or lacquered surfaces:

```gdscript
material.clearcoat_enabled = true
material.clearcoat = 0.5
material.clearcoat_roughness = 0.1
```

**Note:** Adds rendering cost. Use sparingly on mobile.
