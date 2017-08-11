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

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructSurface.glsl"
#include "/lib/util/struct/StructPosition.glsl"
#include "/lib/util/struct/StructMaterial.glsl"

Fragment fragment;

Surface frontSurface;
Surface backSurface;

Position position;

Material frontMaterial;
Material backMaterial;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/Space.glsl"

#include "/lib/util/composite/Sky.glsl"

#include "/lib/util/composite/Shading.glsl"

#include "/lib/util/composite/DepthFog.glsl"

#include "/lib/util/composite/Fog.glsl"

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createSurfaces(frontSurface, backSurface, fragment, texcoord);
  createDepths(position, texcoord);
  createViewPositions(position, texcoord, true, true);
  createMaterial(frontMaterial, frontSurface);
  createMaterial(backMaterial, backSurface);

  // CREATE FRONT AND BACK FRAMES
  mat2x3 frames = mat2x3(0);

  #define backFrame frames[0]
  #define frontFrame frames[1]

  backFrame = backSurface.albedo;
  frontFrame = frontSurface.albedo;

  // RENDER SKY TO BACK FRAME
  if(!getLandMask(position.depthBack)) backFrame = drawSky(normalize(position.viewPositionBack), 0);

  // CALCULATE LIGHT COLOURS
  #include "/lib/util/composite/LightColours.glsl"

  // SHADE BACK FRAME
  if(getLandMask(position.depthBack)) backFrame = doShading(backFrame, lightColours[0], lightColours[1]);

  // RENDER DEPTH FOG TO BACK FRAME
  if(frontMaterial.water > 0.5 || isEyeInWater == 1) backFrame = drawWaterFog(backFrame, lightColours[0]);

  // TINT BACK FRAME THE COLOUR OF FRONT FRAME
  backFrame *= (any(greaterThan(frontFrame, vec3(0.0)))) ? frontFrame : vec3(1.0);

  // POPULATE FRAME WITH BACK FRAME
  fragment.tex0.rgb = backFrame;

  #undef backFrame
  #undef frontFrame

  // SAMPLE FOG
  vec3 fogColour = vec3(0.0);
  fragment.tex5.a   = getFog(fogColour, lightColours[0], lightColours[1]);
  fragment.tex5.rgb = fogColour;
  
  // SEND FRONT SHADOW DOWN FOR SPECULAR HIGHLIGHT
  fragment.tex0.a = shadingStruct.shadowFront;

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:05 */
  gl_FragData[0] = fragment.tex0;
  gl_FragData[1] = fragment.tex5;
}
