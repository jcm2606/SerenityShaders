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

#define TYPE FSH
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
uniform sampler2D texture;

uniform float frameTimeCounter;

// STRUCT
// ARBITRARY
// FUNCTIONS

#include "/lib/util/Materials.glsl"

#include "/lib/util/Normals.glsl"

// MAIN
void main() {
  vec4 albedo = texture2D(texture, texcoord) * colour;
  vec4 aux    = vec4(0.0);

  if(material == MATERIAL_WATER) {
    vec3 normal = waterNormal(worldpos);

    albedo.rgb = vec3(mix(
      mix(0.09, 0.4, clamp01(waterHeight(worldpos))),
      0.3,
      mix(
        pow(1.0 - normal.z, 2.5),
        pow2(1.0 - normal.z),
        0.5
      )
    ));
  }

  albedo.rgb = toLDR(albedo.rgb, COLOUR_RANGE_SHADOW);
  aux.a      = material;

/* DRAWBUFFERS:01 */
  gl_FragData[0] = albedo;
  gl_FragData[1] = aux;
}
