/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

vec3 getTransparentParallax(in vec3 pos, in vec3 viewVector, in float height) {
  const float stepsInv = 1.0 / PARALLAX_TRANSPARENT_STEPS;

  float waveHeight = (waterHeight(pos) * 2.0) * height * stepsInv;

  for(int i = 0; i < PARALLAX_TRANSPARENT_STEPS; i++) {
    pos.xz += waveHeight * (viewVector.xy);
    waveHeight = (waterHeight(pos) * 2.0) * height * stepsInv;
  }

  return pos;
}
