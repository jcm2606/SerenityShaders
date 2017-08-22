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
#define STAGE FINAL

#include "/lib/util/PostHeader.glsl"

// CONST
// USED BUFFERS
#define IN_TEX0

// VARYING
varying vec2 texcoord;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex5;

uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float frameTimeCounter;

uniform int isEyeInWater;

// STRUCT
#include "/lib/util/struct/StructFragment.glsl"

Fragment fragment = FRAGMENT;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/composite/Tonemap.glsl"

#ifdef BLOOM
  #include "/lib/util/composite/Bloom.glsl"
#endif

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  
  // CONVERT FRAME TO HDR
  fragment.tex0.rgb = toHDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  #ifdef BLOOM
    // DRAW SECOND BLOOM PASS
    fragment.tex0.rgb = bloomFinal(fragment.tex0.rgb, texcoord);
  #endif

  // PERFORM TONEMAPPING
  fragment.tex0.rgb = tonemap(fragment.tex0.rgb);

  // CONVERT FRAME TO GAMMA SPACE
  fragment.tex0.rgb = toGamma(fragment.tex0.rgb);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:0 */
  gl_FragData[0] = fragment.tex0;
}
