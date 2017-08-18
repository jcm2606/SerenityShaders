/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

// CONST
// VARYING
varying vec4 coordinates;

varying vec4 colour;

varying mat3 ttn;

flat varying vec2 entity;
flat varying float material;

varying vec3 normal;
varying vec3 normalVector;
varying vec3 worldpos;

#define uvcoord coordinates.xy
#define lmcoord coordinates.zw

// UNIFORM
#if SHADER != GBUFFERS_BASIC && SHADER != GBUFFERS_SKYBASIC
  uniform sampler2D texture;

  #if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_HAND
    uniform sampler2D normals;
    uniform sampler2D specular;
  #endif

  #if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_ENTITIES
    uniform int isEyeInWater;

    uniform mat4 gbufferProjection;
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;

    uniform vec3 cameraPosition;

    uniform sampler2D depthtex1;
  #endif

  uniform float wetness;

  #if SHADER == GBUFFERS_WATER
    uniform float frameTimeCounter;
  #endif
#endif

// STRUCT
// ARBITRARY
// FUNCTIONS

#include "/lib/util/Encoding.glsl"

#include "/lib/util/Materials.glsl"
#include "/lib/util/BlockID.glsl"

#include "/lib/option/PBR.glsl"

#if SHADER == GBUFFERS_WATER
  #include "/lib/util/Normals.glsl"

  #include "/lib/util/gbuffer/ParallaxTransparent.glsl"
#endif

#if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_ENTITIES
  #include "/lib/util/Space.glsl"
  #include "/lib/util/gbuffer/Puddles.glsl"
#endif

// MAIN
void main() {
  vec4 buffer0 = vec4(0.0, 0.0, 0.0, 1.0);
  vec4 buffer1 = vec4(0.0, 0.0, 0.0, 1.0);

  mat3 tbn = mat3(
    ttn[0].x, ttn[1].x, ttn[2].x,
    ttn[0].y, ttn[1].y, ttn[2].y,
    ttn[0].z, ttn[1].z, ttn[2].z
  );

  vec3 view = normalize(tbn * normalVector);

  #include "/lib/util/gbuffer/Data.glsl"

  gl_FragData[0] = buffer0;
  gl_FragData[1] = buffer1;
}

#undef uvcoord
#undef lmcoord
