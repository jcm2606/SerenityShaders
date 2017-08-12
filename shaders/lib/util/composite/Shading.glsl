/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_SHADING

#ifndef INCLUDED_SHADOWSPACE
  #include "/lib/util/ShadowSpace.glsl"
#endif

#ifndef INCLUDED_ABSORPTION
  #include "/lib/util/composite/Absorption.glsl"
#endif

struct Shading {
  float shadowFront;
  float shadowBack;
  float depthBack;
  float shadowSolid;
  float depthSolid;
  float shadowDifference;

  float subsurface;
  float material;

  vec3 shadowColour;
} shadingStruct;

void getShadows() {
  // CALCULATE SHADOW POSITIONS
  mat2x3 shadowPosition = mat2x3(0.0);

  #define shadowPositionFront shadowPosition[0]
  #define shadowPositionBack shadowPosition[1]

  shadowPositionFront = getShadowPosition(getWorldPosition(position.viewPositionFront));
  shadowPositionBack = getShadowPosition(getWorldPosition(position.viewPositionBack));

  // GET AVERAGE DEPTH
  float blocker = 0.0;
  
  for(int i = -1; i <= 1; i++) {
    for(int j = -1; j <= 1; j++) {
      #define width 0.0001
      #define coord(p) vec2(i, j) * width + p

      blocker += texture2DLod(shadowtex0, distortShadowPosition(coord(shadowPositionFront.xy), 1), 5).x;

      #undef width
      #undef coord
    }
  }

  blocker *= 0.111111;

  const float penumbraQualityInv = 1.0 / SHADOW_PENUMBRA_QUALITY;

  float width  = max(0.5E-4, (shadowPositionBack.z - blocker) * 0.01) * penumbraQualityInv;

  // SAMPLE SHADOWS WITH PERCENTAGE-CLOSER FILTER
  int iter = 0;

  vec2 depths = vec2(0.0);
  vec2 coord = vec2(0.0);

  for(int i = -SHADOW_PENUMBRA_QUALITY; i <= SHADOW_PENUMBRA_QUALITY; i++) {
    for(int j = -SHADOW_PENUMBRA_QUALITY; j <= SHADOW_PENUMBRA_QUALITY; j++) {
      coord = vec2(i, j) * width;

      depths.x = texture2D(shadowtex1, distortShadowPosition(coord + shadowPositionBack.xy, 1)).x;
      depths.y = texture2DLod(shadowtex0, distortShadowPosition(coord + shadowPositionBack.xy, 1), 0).x;

      shadingStruct.depthBack += depths.x;
      shadingStruct.depthSolid += depths.y;

      shadingStruct.shadowFront += ceil(compareShadow(texture2DLod(shadowtex0, distortShadowPosition(coord + shadowPositionFront.xy, 1), 0).x, shadowPositionFront.z));
      shadingStruct.shadowBack += ceil(compareShadow(depths.x, shadowPositionBack.z));
      shadingStruct.shadowSolid += ceil(compareShadow(depths.y, shadowPositionBack.z));

      shadingStruct.shadowColour += texture2D(shadowcolor0, distortShadowPosition(coord + shadowPositionBack.xy, 1)).rgb;

      shadingStruct.shadowDifference += sign(compareShadow(depths.x, shadowPositionBack.z) - compareShadow(depths.y, shadowPositionBack.z));

      shadingStruct.material += texture2D(shadowcolor1, distortShadowPosition(coord + shadowPositionBack.xy, 1)).a;

      iter++;
    }
  }

  // AVERAGE VALUES
  shadingStruct.depthBack /= iter;
  shadingStruct.depthSolid /= iter;

  shadingStruct.shadowFront /= iter;
  shadingStruct.shadowBack /= iter;
  shadingStruct.shadowSolid /= iter;

  shadingStruct.shadowColour /= iter;

  shadingStruct.shadowDifference /= iter;

  shadingStruct.subsurface = distance(distortShadowPosition(shadowPositionBack, 1), distortShadowPosition(vec3(shadowPositionBack.xy, shadingStruct.depthSolid), 1));

  shadingStruct.material /= iter;
}

vec3 doShading(in vec3 diffuse, in vec3 direct, in vec3 ambient) {
  // CALCULATE SHADOWING
  getShadows();

  #define directDiffuse max0(dot(fnormalize(backSurface.normal), lightVector))
  #define ambientDiffuse max0(dot(fnormalize(backSurface.normal), upVector) * 0.45 + 0.55)

  #define subsurfaceDiffuse ( (backMaterial.subsurface > 0.5) ? max0(1.0 - pow(shadingStruct.subsurface * 64.0, 0.25)) * 1.5 : 1.0 )

  // TINT DIRECT
  direct *= mix(
    vec3((backMaterial.subsurface > 0.5) ? 1.0 : shadingStruct.shadowSolid),
    toHDR(shadingStruct.shadowColour, COLOUR_RANGE_SHADOW),
    min1(shadingStruct.shadowDifference)
  );

  // ABSORB DIRECT
  if((isEyeInWater == 0 && frontMaterial.water > 0.5) || (isEyeInWater == 1 && frontMaterial.water < 0.5)) direct *= absorbWater(abs(shadingStruct.depthBack - shadingStruct.depthSolid) * 256.0);

  float materialMask = min1(isWithinThreshold(shadingStruct.material, MATERIAL_FOLIAGE, 0.01) + isWithinThreshold(shadingStruct.material, MATERIAL_SUBSURFACE, 0.01));

  #if 0
    return vec3(shadingStruct.aux);
  #else
    return diffuse * mix(
      direct * ((materialMask > 0.5) ? 1.0 : shadingStruct.shadowBack) * mix(directDiffuse, 1.0, backMaterial.subsurface) * subsurfaceDiffuse +
      ambient * ambientDiffuse * pow(backSurface.skyLight, AMBIENT_ATTENUATION) +
      blockLight * pow(backSurface.blockLight, BLOCK_ATTENUATION) * BLOCK_BRIGHTNESS,
      vec3(16.0),
      backSurface.emissive
    );
  #endif

  #undef directDiffuse
  #undef ambientDiffuse

  #undef subsurfaceDiffuse
}
