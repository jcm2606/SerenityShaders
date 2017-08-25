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
#define STAGE COMPOSITE1

#include "/lib/util/PostHeader.glsl"

// CONST
const bool shadowtex0Mipmap = true;
const bool colortex6MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX1
#define IN_TEX2
#define IN_TEX3
#define IN_TEX4

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

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform ivec2 eyeBrightnessSmooth;

uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float wetness;

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructSurface.glsl"
#include "/lib/util/struct/StructPosition.glsl"
#include "/lib/util/struct/StructMaterial.glsl"

Fragment fragment = FRAGMENT;

Surface frontSurface = SURFACE;
Surface backSurface = SURFACE;

Position position = POSITION;

Material frontMaterial = MATERIAL;
Material backMaterial = MATERIAL;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/Space.glsl"

#include "/lib/util/composite/Sky.glsl"

#include "/lib/util/composite/Shading.glsl"

#include "/lib/util/composite/DepthFog.glsl"

#ifdef VOLUMETRIC_FOG
  #include "/lib/util/composite/Fog.glsl"
#endif

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createSurfaces(frontSurface, backSurface, fragment, texcoord);
  createDepths(position, texcoord);
  createViewPositions(position, texcoord, true, true);
  createMaterial(frontMaterial, frontSurface);
  createMaterial(backMaterial, backSurface);

  // CREATE FRAME FROM BACK ALBEDO
  vec3 frame = backSurface.albedo;

  // RENDER SKY
  if(!getLandMask(position.depthBack)) frame = drawSky(position.viewPositionBack, texcoord, 0);

  // CALCULATE LIGHT COLOURS
  mat2x3 lightColours;

  #include "/lib/util/composite/LightColours.glsl"

  // SHADE
  if(getLandMask(position.depthBack)) frame = doShading(frame, lightColours[0], lightColours[1]);

  // RENDER DEPTH FOG
  if(frontMaterial.water > 0.5 || isEyeInWater == 1) frame = drawWaterFog(frame, lightColours[0]);

  // POPULATE TEX0
  fragment.tex0.rgb = frame;

  #ifdef VOLUMETRIC_FOG
    // SAMPLE FOG
    getFog(fragment.tex5, lightColours[0], lightColours[1]);
  #endif
  
  // SEND FRONT SHADOW DOWN FOR SPECULAR HIGHLIGHT
  fragment.tex0.a = (!getLandMask(position.depthBack) && getLandMask(position.depthFront)) ? 1.0 : shadingStruct.shadowFront;

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:05 */
  gl_FragData[0] = fragment.tex0;
  gl_FragData[1] = fragment.tex5;
}
