/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_STARS

#ifndef INCLUDED_NOISE
  #include "/lib/util/Noise.glsl"
#endif

vec3 drawStars(in vec3 view) {
  return vec3(0.5) * (pow16(
    simplex3D( normalize(getWorldPosition(view)) * 128.0 )
  ));
}
