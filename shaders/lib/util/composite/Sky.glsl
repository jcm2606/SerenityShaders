/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_SKY

#ifndef INCLUDED_ATMOSPHERE
  #include "/lib/util/composite/Atmosphere.glsl"
#endif

#ifndef INCLUDED_STARS
  #include "/lib/util/composite/Stars.glsl"
#endif

vec3 drawSky(in vec3 view, in vec2 texcoord, in int mode) {
  vec3 sky = js_getScatter(drawStars(view), fnormalize(view), mode);

  return sky;
}
