/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_ABSORPTION

vec3 absorbWater(in float dist) {
  return pow(waterColor, vec3(dist) * 0.15);
}
