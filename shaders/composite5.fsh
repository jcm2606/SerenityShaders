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
#define STAGE COMPOSITE5

#include "/lib/util/PostHeader.glsl"

// CONST
const bool colortex0MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0

// VARYING
varying vec2 texcoord;

// UNIFORM
uniform sampler2D colortex0;

uniform float viewWidth;
uniform float aspectRatio;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"

Fragment fragment;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/composite/Bloom.glsl"

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  
  // CONVERT FRAME TO HDR
  fragment.tex0.rgb = toHDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  // DRAW FIRST BLOOM PASS
  fragment.tex5.rgb = bloomPrepass(texcoord);

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:05 */
  gl_FragData[0] = fragment.tex0;
  gl_FragData[1] = fragment.tex5;
}
