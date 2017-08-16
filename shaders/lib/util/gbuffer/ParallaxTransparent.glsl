/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

vec3 getTransparentParallax(in vec3 pos, in vec3 viewVector, in float material) {
  const float stepsInv = 1.0 / PARALLAX_TRANSPARENT_STEPS;

  float height = (
    (isWithinThreshold(material, MATERIAL_WATER, 0.01) > 0.5) ? PARALLAX_TRANSPARENT_HEIGHT_WATER : (
      (isWithinThreshold(material, MATERIAL_ICE, 0.01) > 0.5) ? PARALLAX_TRANSPARENT_HEIGHT_ICE : (
        (isWithinThreshold(material, MATERIAL_STAINED_GLASS, 0.01) > 0.5) ? PARALLAX_TRANSPARENT_HEIGHT_STAINED_GLASS : 0.0
      )
    )
  );

  float waveHeight = (getHeight(pos, material) * 2.0) * height * stepsInv;

  for(int i = 0; i < PARALLAX_TRANSPARENT_STEPS; i++) {
    pos.xz += waveHeight * (viewVector.xy);
    waveHeight = (getHeight(pos, material) * 2.0) * height * stepsInv;
  }

  return pos;
}
