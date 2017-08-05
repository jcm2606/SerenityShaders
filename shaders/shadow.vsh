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
#define STAGE SHADOW

#include "/lib/util/PostHeader.glsl"

// CONST
// VARYING
varying vec2 texcoord;

varying vec4 colour;

varying vec3 worldpos;

flat varying vec2 entity;
flat varying float material;

// UNIFORM
attribute vec4 mc_Entity;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform int isEyeInWater;

uniform vec3 cameraPosition;

// STRUCT
// ARBITRARY
// FUNCTIONS

#include "/lib/util/ShadowSpace.glsl"

#include "/lib/util/BlockID.glsl"
#include "/lib/util/Materials.glsl"

// MAIN
void main() {
  colour = gl_Color;

  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

  vec3 position = transMAD(shadowModelViewInverse, transMAD(gl_ModelViewMatrix, gl_Vertex.xyz));

  worldpos = position.xyz + cameraPosition;

  entity = mc_Entity.xz;

  material = 1.0;

  material = (entity.x == WATER.x || entity.x == WATER.y) ? MATERIAL_WATER : material;

  // TODO: Waving terrain.

  gl_Position = transMAD(shadowModelView, position).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];

  gl_Position.xyz = distortShadowPosition(gl_Position.xyz, 0);
}
