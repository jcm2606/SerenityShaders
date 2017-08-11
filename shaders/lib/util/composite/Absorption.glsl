/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_ABSORPTION

vec3 absorbWater(in float dist) {
  return pow(vec3(0.1, 0.5, 0.8), vec3(dist) * 0.25);
}
