/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define PBR_DEFAULT vec3(0.999, 0.02, 0.0)

#define PBR_METAL_IRON vec3(0.2, 0.8, 0.0)
#define PBR_METAL_GOLD vec3(0.1, 0.8, 0.0)

#define PBR_GLOWSTONE vec3(0.7, 0.02, 1.0)

#define PBR_WATER vec3(0.13, 0.05, 0.0)

#define PBR_ICE vec3(0.1, 0.05, 0.0)

#define PBR_STAINED_GLASS vec3(0.17, 0.02, 0.0)

void getFallbackPBR(in vec2 entity, out float roughness, out float f0, out float emission) {
  vec3 pbr = PBR_DEFAULT;

  pbr = (entity.x == BLOCK_IRON.x) ? PBR_METAL_IRON : pbr;

  pbr = (entity.x == BLOCK_GOLD.x) ? PBR_METAL_GOLD : pbr;

  pbr = (entity.x == GLOWSTONE.x) ? PBR_GLOWSTONE : pbr;

  pbr = (entity.x == WATER.x || entity.x == WATER.y) ? PBR_WATER : pbr;

  pbr = (entity.x == ICE.x) ? PBR_ICE : pbr;

  pbr = (entity.x == STAINED_GLASS.x) ? PBR_STAINED_GLASS : pbr;

  roughness = pbr.x;
  f0 = pbr.y;
  emission = pbr.z;
}
