/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

const float pi  = 3.14159265358979;
const float tau = 6.28318530718;

const float gammaCurve        = 2.2;
const float inverseGammaCurve = 1.0 / gammaCurve;

float getLuma(in vec3 colour) { return dot(colour, vec3(0.2125, 0.7154, 0.0721)); }
vec3 colourSaturation(in vec3 colour, in float saturation) { return colour * saturation + getLuma(colour) * (1.0 - saturation); }

#include "/lib/Settings.glsl"

#include "/lib/util/syntax/Macros.glsl"
#include "/lib/util/syntax/Vector.glsl"
#include "/lib/util/syntax/Matrix.glsl"
#include "/lib/util/syntax/Functions.glsl"

#define frametime frameTimeCounter * GLOBAL_SPEED

#define upVector gbufferModelView[1].xyz

const mat3 gaussianWeights = mat3(
  1, 2, 1,
  2, 3, 2,
  1, 2, 1
);
