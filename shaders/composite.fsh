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

// UNIFORM
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform float near;
uniform float far;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructPosition.glsl"

Fragment fragment;

Position position;

// ARBITRARY
// FUNCTIONS

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createDepths(position, texcoord);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:5 */
  gl_FragData[0] = fragment.tex5;
}
