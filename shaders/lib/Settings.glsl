/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#include "/lib/option/Post.glsl"
#include "/lib/option/Normals.glsl"
#include "/lib/option/Shading.glsl"
#include "/lib/option/Parallax.glsl"
#include "/lib/option/Bloom.glsl"
#include "/lib/option/DOF.glsl"
#include "/lib/option/Fog.glsl"
#include "/lib/option/Refraction.glsl"

#ifndef MC_SEA_LEVEL
  #define MC_SEA_LEVEL 64.0
#endif

const float sunPathRotation = -30.0;

const float centerDepthHalflife = 2.0;

const int noiseTextureResolution = 256;

const float wetnessHalflife = 400.0;
const float drynessHalflife = 40.0;

//#define LSD_MODE

const vec3 waterColor = vec3(0.1, 0.5, 0.9);

#define GLOBAL_SPEED 1.0 // [0.0625 0.125 0.25 0.5 1.0 2.0 4.0 8.0 16.0]

#define RESOURCE_FORMAT 2 // 0 - Hardcoded. 1 - Specular. 2 - Old PBR, no emissive. 3 - Old PBR, emissive. 4 - New PBR. [0 1 2 3 4]

#define COLOUR_RANGE_COMPOSITE 48.0
#define COLOUR_RANGE_FOG       48.0
#define COLOUR_RANGE_SHADOW    4.0
