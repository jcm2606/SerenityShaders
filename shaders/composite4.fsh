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
#define STAGE COMPOSITE4

#include "/lib/util/PostHeader.glsl"

// CONST
const bool colortex0MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2

// VARYING
varying vec2 texcoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform float near;
uniform float far;
uniform float centerDepthSmooth;
uniform float aspectRatio;
uniform float frameTimeCounter;

uniform int isEyeInWater;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructPosition.glsl"
#include "/lib/util/struct/StructSurface.glsl"
#include "/lib/util/struct/StructMaterial.glsl"

Fragment fragment;

Position position;

Surface backSurface;

Material backMaterial;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/composite/DOF.glsl"

#include "/lib/util/composite/LSD.glsl"

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createDepths(position, texcoord);
  createSurface(backSurface, fragment.tex1, fragment.tex2, texcoord);
  createMaterial(backMaterial, backSurface);
  
  // CONVERT FRAME TO HDR
  fragment.tex0.rgb = toHDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  // DRAW DOF
  #ifndef LSD_MODE
    #ifdef DOF
      if(backMaterial.hand < 0.5) fragment.tex0.rgb = doDOF(position.depthBack);
    #endif
  #endif

  // DRAW LSD MODE
  #ifdef LSD_MODE
    fragment.tex0.rgb = drawLSDMode(texcoord);
  #endif

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = fragment.tex0;
}
