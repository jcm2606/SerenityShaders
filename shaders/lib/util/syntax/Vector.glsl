/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

const vec2 swizzle2 = vec2(1.0, 0.0);
const vec3 swizzle3 = vec3(1.0, 0.0, 0.5);

#define reverse2(v) v.yx
#define reverse3(v) v.zyx

void swap2(inout vec2 a, inout vec2 b) {
  vec2 temp = a;
  a = b;
  b = temp;
}

void swap3(inout vec3 a, inout vec3 b) {
  vec3 temp = a;
  a = b;
  b = temp;
}
