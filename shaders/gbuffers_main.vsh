/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

// CONST
// VARYING
varying vec4 coordinates;

varying vec4 colour;

varying mat3 ttn;

flat varying vec2 entity;
flat varying float material;

varying vec3 normal;
varying vec3 normalVector;
varying vec3 worldpos;

#define uvcoord coordinates.xy
#define lmcoord coordinates.zw

// UNIFORM
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
attribute vec4 at_tangent;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// STRUCT
// ARBITRARY
// FUNCTIONS

#include "/lib/util/BlockID.glsl"
#include "/lib/util/Materials.glsl"

// MAIN
void main() {
  colour = gl_Color;

  uvcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  normal = normalize(gl_NormalMatrix * gl_Normal);

  entity = mc_Entity.xz;

  #include "/lib/util/gbuffer/Material.glsl"

  #if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_WATER
    //vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    vec3 position = transMAD(gbufferModelViewInverse, transMAD(gl_ModelViewMatrix, gl_Vertex.xyz));

    worldpos = position.xyz + cameraPosition;
  #endif

  // TODO: Waving terrain.

  #if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_WATER
    //position = gbufferModelView * position;
    //gl_Position = gl_ProjectionMatrix * position;

    gl_Position = transMAD(gbufferModelView, position.xyz).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
  #else
    gl_Position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
  #endif

  normalVector = (gl_ModelViewMatrix * gl_Vertex).xyz;

  ttn = mat3(
    fnormalize(gl_NormalMatrix * at_tangent.xyz),
    fnormalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w),
    fnormalize(gl_NormalMatrix * gl_Normal)
  );
}

#undef uvcoord
#undef lmcoord
