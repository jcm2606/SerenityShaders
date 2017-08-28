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
#define STAGE COMPOSITE2

#include "/lib/util/PostHeader.glsl"

// CONST
const bool colortex5MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX3
#define IN_TEX4

// VARYING
varying vec2 texcoord;

flat varying vec3 sunVector;
flat varying vec3 moonVector;
flat varying vec3 lightVector;

flat varying vec4 timeVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int isEyeInWater;
uniform int worldTime;
uniform int moonPhase;

uniform float frameTimeCounter;
uniform float near;
uniform float far;
uniform float rainStrength;
uniform float wetness;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 cameraPosition;

// STRUCT
#include "/lib/util/Encoding.glsl"

#include "/lib/util/struct/StructFragment.glsl"
#include "/lib/util/struct/StructSurface.glsl"
#include "/lib/util/struct/StructPosition.glsl"
#include "/lib/util/struct/StructMaterial.glsl"

Fragment fragment = FRAGMENT;

Surface frontSurface = SURFACE;
Surface backSurface = SURFACE;

Position position = POSITION;

Material frontMaterial = MATERIAL;
Material backMaterial = MATERIAL;

// ARBITRARY
// FUNCTIONS

#include "/lib/util/Space.glsl"

#ifdef REFRACTION
  #include "/lib/util/composite/Refraction.glsl"
#endif

#ifdef VOLUMETRIC_FOG
  #include "/lib/util/composite/Fog.glsl"
#endif

#ifdef VOLUME_CLOUDS
  #include "/lib/util/composite/Atmosphere.glsl"

  #include "/lib/util/composite/VolumeClouds.glsl"
#endif

// MAIN
void main() {
  // POPULATE STRUCTS
  createFragment(fragment, texcoord);
  createSurfaces(frontSurface, backSurface, fragment, texcoord);
  createDepths(position, texcoord);
  createViewPositions(position, texcoord, true, true);
  createMaterial(frontMaterial, frontSurface);
  createMaterial(backMaterial, backSurface);
  
  // CONVERT FRAME TO HDR
  fragment.tex0.rgb = toHDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);

  vec2 refractOffset = vec2(0.0);

  #ifdef REFRACTION
    // CALCULATE REFRACTION OFFSET
    if(frontMaterial.water > 0.5 || frontMaterial.ice > 0.5 || frontMaterial.stainedGlass > 0.5) refractOffset = getRefractionOffset();

    fragment.tex6.rg = refractOffset * 0.5 + 0.5;

    // DRAW REFRACTION
    if(frontMaterial.water > 0.5 || frontMaterial.ice > 0.5 || frontMaterial.stainedGlass > 0.5) fragment.tex0.rgb = drawRefraction(refractOffset);
  #endif

  // TINT FRAME WITH FRONT ALBEDO
  fragment.tex0.rgb *= (any(greaterThan(frontSurface.albedo, vec3(0.0)))) ? frontSurface.albedo : vec3(1.0);

  vec4 fog = vec4(0.0);

  #ifdef VOLUMETRIC_FOG
    // DRAW FOG
    fragment.tex0.rgb = drawFog(fragment.tex0.rgb, fog, texcoord, refractOffset);
  #endif

  #ifdef VOLUME_CLOUDS
    // GENERATE LIGHTING COLOURS
    mat2x3 lightColours = mat2x3(0.0);

    #include "/lib/util/composite/LightColours.glsl"

    // GENERATE VOLUMETRIC CLOUDS
    fragment.tex5 = getVolumeClouds(position.viewPositionBack, texcoord, lightColours[0], lightColours[1], fog, 0);
  #endif

  // CONVERT FRAME TO LDR
  fragment.tex0.rgb = toLDR(fragment.tex0.rgb, COLOUR_RANGE_COMPOSITE);
  
  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:056 */
  gl_FragData[0] = fragment.tex0;
  gl_FragData[1] = fragment.tex5;
  gl_FragData[2] = fragment.tex6;
}
