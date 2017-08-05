/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_NORMALS

#ifndef INCLUDED_NOISE
  #include "/lib/util/Noise.glsl"
#endif

#define rot2(a) mat2(cos(a), -sin(a), sin(a), cos(a))

// WATER
float water0(in vec2 position) {
  float height = 0.0;

  position *= 0.35;
  position *= rot2(0.7);

  vec2 move = swizzle2 * frametime * 0.35;
  const vec2 stretch = vec2(1.0, 0.75);

  height += simplex2D(position * vec2(1.0, 0.55) + move * 0.5) * 1.0;
  height += simplex2D(position * vec2(1.0, 0.65) * 1.5 + move * 2.0) * 0.5;
  height += simplex2D(position * vec2(1.0, 0.75) * 2.0 + move * 4.0) * 0.25;

  position *= rot2(0.7);
  height += simplex2D(position * 4.0 + move * 4.0) * 0.125;

  height *= 0.45;

  return height;
}

float waterHeight(in vec3 position) {
  #if NORMAL_WATER_TYPE == 0
    return water0(position.xz - position.y);
  #else
    return 0.0;
  #endif
}

vec3 waterNormal(in vec3 position) {
  float height0 = waterHeight(position);

  const float deltaPos =        0.2;
  const float inverseDeltaPos = 1.0 / deltaPos;

  vec4 heightVector = vec4(0.0);

  #define height1 heightVector.x
  #define height2 heightVector.y
  #define height3 heightVector.z
  #define height4 heightVector.w

  height1 = waterHeight(position + vec3( deltaPos, 0.0, 0.0));
  height2 = waterHeight(position + vec3(-deltaPos, 0.0, 0.0));
  height3 = waterHeight(position + vec3(0.0, 0.0,  deltaPos));
  height4 = waterHeight(position + vec3(0.0, 0.0, -deltaPos));

  vec2 delta = vec2(0.0);

  delta.x = ((height1 - height0) + (height0 - height2)) * inverseDeltaPos;
  delta.y = ((height3 - height0) + (height0 - height4)) * inverseDeltaPos;

  return fnormalize(vec3(delta.x, delta.y, 1.0 - pow2(delta.x) - pow2(delta.y)));

  #undef height1
  #undef height2
  #undef height3
  #undef height4
}

// ICE
vec3 iceNormal(in vec3 position) {
  return vec3(0.5, 0.5, 1.0);
}

// STAINED GLASS
vec3 stainedGlassNormal(in vec3 position) {
  return vec3(0.5, 0.5, 1.0);
}
