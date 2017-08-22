/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_FUNCTIONS

#include "/lib/util/syntax/Power.glsl"

float flengthsqr(in vec2 n) { return dot(n, n); }
float flengthsqr(in vec3 n) { return dot(n, n); }
float flengthsqr(in vec4 n) { return dot(n, n); }

float flength(in vec2 n) { return sqrt(flengthsqr(n)); }
float flength(in vec3 n) { return sqrt(flengthsqr(n)); }
float flength(in vec4 n) { return sqrt(flengthsqr(n)); }

float flengthinv(in vec3 n) { return inversesqrt(flengthsqr(n)); }

vec3 fnormalize(in vec3 n) { return n * flengthinv(n); }

vec3 toGamma(in vec3 colour)  { return pow(colour, vec3(inverseGammaCurve)); }
vec3 toLinear(in vec3 colour) { return pow(colour, vec3(gammaCurve)); }

vec3 toLDR(in vec3 colour, in float range) { return toGamma(colour / range);  }
vec3 toHDR(in vec3 colour, in float range) { return toLinear(colour) * range; }

float compareShadow(in float depth, in float comparison) { return clamp01(1.0 - max0(comparison - depth) * float(shadowMapResolution)); }

float isWithinThreshold(in float x, in float y, in float threshold) {  return max0(sign(x - (y - threshold)) * sign(y + (threshold - x))); }

float linearDepth(in float depth, in float near, in float far) { return 2.0 * near * far / (far + near - (depth * 2.0 - 1.0) * (far - near)); }
