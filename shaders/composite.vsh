/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#version 120
#extension GL_EXT_gpu_shader4 : enable

// HEADER
#include "/lib/util/PreHeader.glsl"

#define TYPE VSH
#define SHADER NONE
#define STAGE COMPOSITE

#include "/lib/util/PostHeader.glsl"

// CONST
// VARYING
varying vec2 texcoord;

// UNIFORM
// STRUCT
// ARBITRARY
// FUNCTIONS
// MAIN
void main() {
  texcoord = gl_MultiTexCoord0.xy;

  gl_Position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
}
