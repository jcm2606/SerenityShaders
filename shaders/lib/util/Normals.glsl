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

// WATER
float water0(in vec2 position) {
  float height = 0.0;

  position *= 0.35;
  position *= rot2(windDirection);

  vec2 move = swizzle2 * frametime * 0.15;
  const vec2 stretch = vec2(1.0, 0.75);

  height += simplex2D(position * vec2(1.0, 0.55) + move * 1.0) * 1.0;
  height += simplex2D(position * vec2(1.0, 0.65) * 1.5 + move * 4.0) * 0.5;
  height += simplex2D(position * vec2(1.0, 0.75) * 2.0 + move * 8.0) * 0.25;

  position *= rot2(windDirection);
  height += simplex2D(position * 4.0 + move * 4.0) * 0.125;

  height *= mix(0.4, 0.6, rainStrength);

  return height;
}

float water1(in vec2 position) {
  float height = 0.0;

  position *= 0.75;

  vec2 move = swizzle2 * frametime * 0.55;

  position *= rot2(windDirection);
  height += simplex2D(move * 1.0 + position);

  position *= rot2(windDirection);
  height -= simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height += simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height += simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height -= simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height += simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height -= simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height += simplex2D(move * 1.0 + position * 1.0);

  position *= rot2(windDirection);
  height -= simplex2D(move * 1.0 + position * 1.0);

  height *= mix(0.1, 0.6, rainStrength);

  return height;
}

float waterHeight(in vec3 position) {
  #if   NORMAL_WATER_TYPE == 0
    return water0(position.xz - position.y);
  #elif NORMAL_WATER_TYPE == 1
    return water1(position.xz - position.y);
  #else
    return 0.0;
  #endif
}

// ICE
float ice0(in vec3 position) {
  float height = 0.0;

  height += simplex3D(position) * 0.5;
  height += simplex3D(position * 2.0) * 0.25;
  height += simplex3D(position * 4.0) * 0.25;

  height *= 0.2;

  return height;
}

float iceHeight(in vec3 position) {
  #if NORMAL_ICE_TYPE == 0
    return ice0(position);
  #else
    return 0.0;
  #endif
}

// STAINED GLASS
float stainedGlass0(in vec3 position) {
  float height = 0.0;

  height += simplex3D(position) * 0.5;
  height += simplex3D(position * 2.0) * 0.25;
  height += simplex3D(position * 4.0) * 0.25;

  height *= 0.15;

  return height;
}

float stainedGlassHeight(in vec3 position) {
  #if NORMAL_ICE_TYPE == 0
    return stainedGlass0(position);
  #else
    return 0.0;
  #endif
}

// GENERIC
float getHeight(in vec3 position, in float material) {
  return (
    (isWithinThreshold(material, MATERIAL_WATER, 0.01) > 0.5) ? waterHeight(position) : (
      (isWithinThreshold(material, MATERIAL_ICE, 0.01) > 0.5) ? iceHeight(position) : (
        (isWithinThreshold(material, MATERIAL_STAINED_GLASS, 0.01) > 0.5) ? stainedGlassHeight(position) : 0.0
      )
    )
  );
}

vec3 getNormal(in vec3 position, in float material) {
  const float inverseDeltaPos = 1.0 / NORMAL_DELTA;

  float height0 = getHeight(position, material);
  vec4 heightVector = vec4(0.0);

  #define height1 heightVector.x
  #define height2 heightVector.y
  #define height3 heightVector.z
  #define height4 heightVector.w

  height1 = getHeight(position + vec3( NORMAL_DELTA, 0.0, 0.0), material);
  height2 = getHeight(position + vec3(-NORMAL_DELTA, 0.0, 0.0), material);
  height3 = getHeight(position + vec3(0.0, 0.0,  NORMAL_DELTA), material);
  height4 = getHeight(position + vec3(0.0, 0.0, -NORMAL_DELTA), material);

  vec2 delta = vec2(0.0);

  delta.x = ((height1 - height0) + (height0 - height2)) * inverseDeltaPos;
  delta.y = ((height3 - height0) + (height0 - height4)) * inverseDeltaPos;

  return fnormalize(vec3(delta.x, delta.y, 1.0 - pow2(delta.x) - pow2(delta.y)));

  #undef height1
  #undef height2
  #undef height3
  #undef height4
}
