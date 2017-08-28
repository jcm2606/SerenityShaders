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
#define STAGE COMPOSITE3

#include "/lib/util/PostHeader.glsl"

// CONST
const bool colortex5MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX3
#define IN_TEX4
#define IN_TEX6

// VARYING
varying vec2 texcoord;

flat varying vec3 sunVector;
flat varying vec3 moonVector;
flat varying vec3 lightVector;

flat varying vec4 timeVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform float near;
uniform float far;
uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructSurface.glsl"
#include "/lib/util/struct/StructPosition.glsl"

Fragment fragment = FRAGMENT;

Surface frontSurface = SURFACE;
Surface backSurface = SURFACE;

Position position = POSITION;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/Space.glsl"

#ifdef VOLUME_CLOUDS
  #include "/lib/util/composite/VolumeClouds.glsl"
#endif

#include "/lib/util/composite/Reflection.glsl"

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createSurfaces(frontSurface, backSurface, fragment, texcoord);
  createDepths(position, texcoord);
  createViewPositions(position, texcoord, true, true);
  
  // CONVERT FRAME TO HDR
  fragment.tex0.rgb = toHDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  // CALCULATE LIGHT COLOURS
  mat2x3 lightColours;

  if(getLandMask(position.depthFront) && isEyeInWater == 0) {
    #include "/lib/util/composite/LightColours.glsl"
  } else {
    lightColours = mat2x3(0.0);
  }

  // DRAW REFLECTIONS
  if(getLandMask(position.depthFront) && isEyeInWater == 0) fragment.tex0.rgb = drawReflection(fragment.tex0.rgb, lightColours[0], lightColours[1]);

  #ifdef VOLUME_CLOUDS
    fragment.tex0.rgb = drawVolumeClouds(fragment.tex0.rgb, texcoord);
  #endif

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = fragment.tex0;
}
