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
#define STAGE COMPOSITE2

#include "/lib/util/PostHeader.glsl"

// CONST
const bool colortex5MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX3
#define IN_TEX4

// VARYING
varying vec2 texcoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform float frameTimeCounter;
uniform float near;
uniform float far;
uniform float rainStrength;

uniform vec3 cameraPosition;

uniform int isEyeInWater;

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

#include "/lib/util/composite/Refraction.glsl"

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
  
  // CONVERT FRAME TO HDR
  fragment.tex0.rgb = toHDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  // CALCULATE REFRACTION OFFSET
  vec2 refractOffset = vec2(0.0);
  
  if(frontMaterial.water > 0.5 || frontMaterial.ice > 0.5 || frontMaterial.stainedGlass > 0.5) refractOffset = getRefractionOffset();

  // DRAW REFRACTION
  if(frontMaterial.water > 0.5 || frontMaterial.ice > 0.5 || frontMaterial.stainedGlass > 0.5) fragment.tex0.rgb = drawRefraction(refractOffset);

  // TINT FRAME WITH FRONT ALBEDO
  fragment.tex0.rgb *= (any(greaterThan(frontSurface.albedo, vec3(0.0)))) ? frontSurface.albedo : vec3(1.0);

  // DRAW FOG
  fragment.tex0.rgb = drawFog(fragment.tex0.rgb, texcoord, refractOffset);

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = fragment.tex0;
}
