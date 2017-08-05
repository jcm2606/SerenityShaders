/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_SHADOWSPACE

#ifndef INCLUDED_SPACE
  #include "/lib/util/Space.glsl"
#endif

mat4 shadowMatrix = shadowProjection * shadowModelView * 0.5;

vec3 getShadowPosition(in vec3 world) {
  return (transMAD(shadowMatrix, world) + 0.5);
}

vec3 getShadowWorldPosition(in vec3 shadowPosition) {
  vec4 spos = vec4(shadowPosition, 1.0) * 2.0 - 1.0;
  spos = shadowProjectionInverse * spos;
  spos = shadowModelViewInverse * spos;
  spos /= spos.w;

  return spos.xyz;
}

vec2 distortShadowPosition(in vec2 shadowPosition, in int rangeConversion) {
  shadowPosition = (rangeConversion == 0) ? shadowPosition : shadowPosition * 2.0 - 1.0;
  shadowPosition /= flength(shadowPosition) * SHADOW_BIAS + (1.0 - SHADOW_BIAS);
  shadowPosition = (rangeConversion == 0) ? shadowPosition : shadowPosition * 0.5 + 0.5;

  return shadowPosition;
}

vec3 distortShadowPosition(in vec3 shadowPosition, in int rangeConversion) {
  shadowPosition.xy = distortShadowPosition(shadowPosition.xy, rangeConversion);
  
  return shadowPosition;
}
