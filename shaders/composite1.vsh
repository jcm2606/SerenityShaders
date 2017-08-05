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
#define STAGE COMPOSITE1

#include "/lib/util/PostHeader.glsl"

// CONST
// VARYING
varying vec2 texcoord;

flat varying vec3 sunVector;
flat varying vec3 moonVector;
flat varying vec3 lightVector;

flat varying vec4 timeVector;

// UNIFORM
uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform float sunAngle;

// STRUCT
// ARBITRARY
// FUNCTIONS
// MAIN
void main() {
  texcoord = gl_MultiTexCoord0.xy;

  gl_Position = ftransform();

  #include "/lib/util/composite/Vectors.glsl"

  #include "/lib/util/Time.glsl"
}
