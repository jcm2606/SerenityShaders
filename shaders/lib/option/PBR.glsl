#define PBR_DEFAULT vec3(0.999, 0.02, 0.0)

#define PBR_METAL_IRON vec3(0.2, 0.8, 0.0)
#define PBR_METAL_GOLD vec3(0.1, 0.8, 0.0)

#define PBR_GLOWSTONE vec3(0.7, 0.02, 1.0)

void getFallbackPBR(in vec2 entity, out float roughness, out float f0, out float emission) {
  vec3 pbr = PBR_DEFAULT;

  pbr = (entity.x == BLOCK_IRON.x) ? PBR_METAL_IRON : pbr;

  pbr = (entity.x == BLOCK_GOLD.x) ? PBR_METAL_GOLD : pbr;

  pbr = (entity.x == GLOWSTONE.x) ? PBR_GLOWSTONE : pbr;

  roughness = pbr.x;
  f0 = pbr.y;
  emission = pbr.z;
}
