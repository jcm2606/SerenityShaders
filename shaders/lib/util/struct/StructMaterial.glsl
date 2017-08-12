/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#ifndef INCLUDED_MATERIALS
  #include "/lib/util/Materials.glsl"
#endif

struct Material {
  float hand;
  float entity;
  float weather;
  float particle;

  float terrain;
  float foliage;

  float water;
  float translucent;
  float ice;
  float stainedGlass;

  float subsurface;
};

#define MATERIAL_THRESHOLD 0.01

void createMaterial(inout Material material, inout Surface surface) {
  float mat = surface.material;

  material.hand = isWithinThreshold(MATERIAL_HAND, mat, MATERIAL_THRESHOLD);
  material.entity = isWithinThreshold(MATERIAL_ENTITY, mat, MATERIAL_THRESHOLD);
  material.weather = isWithinThreshold(MATERIAL_WEATHER, mat, MATERIAL_THRESHOLD);
  material.particle = isWithinThreshold(MATERIAL_PARTICLE, mat, MATERIAL_THRESHOLD);

  material.terrain = isWithinThreshold(MATERIAL_TERRAIN, mat, MATERIAL_THRESHOLD);
  material.foliage = isWithinThreshold(MATERIAL_FOLIAGE, mat, MATERIAL_THRESHOLD);

  material.water = isWithinThreshold(MATERIAL_WATER, mat, MATERIAL_THRESHOLD);
  material.translucent = isWithinThreshold(MATERIAL_TRANSLUCENT, mat, MATERIAL_THRESHOLD);
  material.ice = isWithinThreshold(MATERIAL_ICE, mat, MATERIAL_THRESHOLD);
  material.stainedGlass = isWithinThreshold(MATERIAL_STAINED_GLASS, mat, MATERIAL_THRESHOLD);

  material.subsurface = min1(isWithinThreshold(MATERIAL_SUBSURFACE, mat, MATERIAL_THRESHOLD) + material.foliage);
}

#undef MATERIAL_THRESHOLD
