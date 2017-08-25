/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#ifndef INCLUDED_RAYTRACER
  #include "/lib/util/composite/Raytracer.glsl"
#endif

#ifndef INCLUDED_SKY
  #include "/lib/util/composite/Sky.glsl"
#endif

float GGX (vec3 n, vec3 v, vec3 l, float r, float F0) {
  r*=r;r*=r;
  vec3 h = normalize(l + v);

  float dotLH = max(0., dot(l,h));
  float dotNH = max(0., dot(n,h));
  float dotNL = max(0., dot(n,l));
  
  float denom = (dotNH * r - dotNH) * dotNH + 1.;
  float D = r / (3.141592653589793 * denom * denom);
  float F = F0 + (1. - F0) * pow(1.-dotLH,5.);
  float k2 = .25 * r;

  return dotNL * D * F / (dotLH*dotLH*(1.0-k2)+k2);
}

vec3 halfVector(in vec3 a, in vec3 b) {
  return normalize(a - b);
}

float fresnelSchlick(in float angle, in float f0) {
  return f0 + (1.0 - f0) * pow5(1.0 - max0(angle));
}

float ggx(in vec3 view, in vec3 normal, in vec3 light, in float roughness, in float metal, in float f0) {
  roughness = clamp(roughness, 0.05, 0.99);

  float alpha = pow2(roughness);

  vec3 halfVector = halfVector(light, view);

  float alphaSqr = pow2(alpha);

  float k2 = pow2(((metal > 0.5) ? 0.5 : 2.0) * alpha);

  return max0(dot(normal, light)) * alphaSqr / (pi * pow2(pow2(max0(dot(normal, halfVector))) * (alphaSqr - 1.0) + 1.0)) * fresnelSchlick(dot(halfVector, light), f0) / (pow2(max0(dot(light, halfVector))) * (1.0 - k2) + k2);
}

vec3 drawReflection(in vec3 diffuse, in vec3 direct, in vec3 ambient) {
  vec4 reflection = vec4(0.0);

  vec3 viewdir = -fnormalize(position.viewPositionFront);
  vec3 normal = fnormalize(selectSurface().normal);
  float roughness = selectSurface().roughness;
  float f0 = selectSurface().f0;
  float metallic = (f0 > 0.5) ? 1.0 : 0.0;

  // CREATE A REFLECTED DIRECTION
  vec3 rview = reflect(fnormalize(position.viewPositionFront), normal);

  // PERFORM RAYTRACE OPERATION
  reflection = raytrace(rview, position.viewPositionFront);

  // CONVERT RAYTRACED REFLECTION TO HDR
  reflection.rgb = toHDR(reflection.rgb, COLOUR_RANGE_COMPOSITE);

  // SAMPLE SKY IN REFLECTED DIRECTION
  vec3 sky = drawSky(rview, texcoord, 1) * 2.0;
  
  #ifdef VOLUME_CLOUDS
    #ifdef VOLUME_CLOUDS_REFLECTION
      vec4 volumeClouds = getVolumeClouds(reflect(position.viewPositionFront, selectSurface().normal), texcoord, direct, ambient, vec4(0.0), 1);

      sky = mix(sky, volumeClouds.rgb, clamp01(volumeClouds.a));
    #endif
  #endif

  // MIX BETWEEN RAYTRACED AND SKY SAMPLES
  reflection.rgb = mix(sky, reflection.rgb, reflection.a);

  // APPLY FRESNEL
  reflection.rgb *= ((1.0 - f0) * pow5(1.0 - max0(dot(viewdir, fnormalize(rview + viewdir)))) + f0) * max0(1.0 - pow2(roughness * 1.9));

  // APPLY SPECULAR HIGHLIGHT
  reflection.rgb += direct * ggx(fnormalize(position.viewPositionFront), normal, lightVector, roughness, metallic, f0) * fragment.tex0.a;

  // APPLY METALLIC TINTING
  reflection.rgb *= (metallic > 0.5) ? selectSurface().albedo : vec3(1.0);

  return diffuse * (1.0 - metallic) + reflection.rgb;
}
