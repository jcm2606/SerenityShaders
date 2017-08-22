/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable
//#extension GL_ARB_shader_texture_lod : enable 

// HEADER
#include "/lib/util/PreHeader.glsl"

#define TYPE FSH
#define SHADER NONE
#define STAGE COMPOSITE

#include "/lib/util/PostHeader.glsl"

// CONST
// USED BUFFERS
// VARYING
varying vec2 texcoord;

flat varying vec3 sunVector;
flat varying vec3 moonVector;
flat varying vec3 lightVector;

flat varying vec4 timeVector;

// UNIFORM
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float wetness;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructPosition.glsl"

Fragment fragment = FRAGMENT;

Position position = POSITION;

// ARBITRARY
// FUNCTIONS

#ifdef VOLUME_CLOUDS
  #include "/lib/util/composite/Atmosphere.glsl"

  #include "/lib/util/composite/VolumeClouds.glsl"
#endif

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createDepths(position, texcoord);
  createViewPositions(position, texcoord, false, true);

  #ifdef VOLUME_CLOUDS
    // GENERATE LIGHTING COLOURS
    mat2x3 lightColours = mat2x3(0.0);

    #include "/lib/util/composite/LightColours.glsl"

    // GENERATE VOLUMETRIC CLOUDS
    fragment.tex6 = getVolumeClouds(position.viewPositionBack, texcoord, lightColours[0], lightColours[1]);
  #endif
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:56 */
  gl_FragData[0] = fragment.tex5;
  gl_FragData[1] = fragment.tex6;
}
