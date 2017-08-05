/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#ifndef INCLUDED_ABSORPTION
  #include "/lib/util/composite/Absorption.glsl"
#endif

vec3 drawWaterFog(in vec3 diffuse, in vec3 direct) {
  float dist = distance(position.viewPositionBack * (1.0 - isEyeInWater), position.viewPositionFront);

  return mix(
    diffuse * absorbWater(dist),
    vec3(0.1, 0.5, 0.9) * mix(0.0, 0.04, min1((1.0 - isEyeInWater) + (eyeBrightnessSmooth.y / 240.0))) * direct,
    1.0 - exp2(-dist * 0.3)
  );
}
