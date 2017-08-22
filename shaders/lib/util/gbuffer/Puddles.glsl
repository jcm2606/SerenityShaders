/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_PUDDLES

#ifndef INCLUDED_NOISE
  #include "/lib/util/Noise.glsl"
#endif

float getPuddles(in vec3 world, in float skyLight, in float heightmap) {
  float puddle = 0.0;

  world *= 0.1;
  world.y *= 0.1;

  puddle = (max0(simplex3D(world))) + puddle;
  puddle = (max0(simplex3D(world * 4.0)) * 0.5) * puddle + puddle;
  puddle = (max0(simplex3D(world * 8.0)) * 0.25) * puddle + puddle;

  puddle *= 1.25;
  puddle = clamp01(puddle);

  return max(pow(puddle, 0.5), 0.475) * pow4(skyLight) * wetness * (max0(1.0 - heightmap) * 2.0 + 1.0);
}

vec3 getPuddleNormal(in vec3 world, in float skyLight, in float heightmap) {
  const float deltaPos = 0.1;
  const float inverseDeltaPos = 1.0 / deltaPos;

  float puddle0 = getPuddles(world, skyLight, heightmap);

  vec4 puddles = vec4(0.0);

  #define puddle1 puddles.x
  #define puddle2 puddles.y
  #define puddle3 puddles.z
  #define puddle4 puddles.w

  puddle1 = getPuddles(world + vec3( deltaPos, 0.0, 0.0), skyLight, heightmap);
  puddle2 = getPuddles(world + vec3(-deltaPos, 0.0, 0.0), skyLight, heightmap);
  puddle3 = getPuddles(world + vec3(0.0, 0.0,  deltaPos), skyLight, heightmap);
  puddle4 = getPuddles(world + vec3(0.0, 0.0, -deltaPos), skyLight, heightmap);

  vec2 delta = vec2(0.0);

  delta.x = ((puddle1 - puddle0) + (puddle0 - puddle2)) * inverseDeltaPos;
  delta.y = ((puddle3 - puddle0) + (puddle0 - puddle4)) * inverseDeltaPos;

  return fnormalize(vec3(delta.x, delta.y, 1.0 - pow2(delta.x) - pow2(delta.y)));

  #undef puddle1
  #undef puddle2
  #undef puddle3
  #undef puddle4
}
