/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable 

// HEADER
#include "/lib/util/PreHeader.glsl"

#define TYPE FSH
#define SHADER GBUFFERS_WATER
#define STAGE GBUFFERS

#include "/lib/util/PostHeader.glsl"

/* DRAWBUFFERS:34 */
#include "/gbuffers_main.fsh"
