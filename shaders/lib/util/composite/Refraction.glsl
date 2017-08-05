/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#ifndef INCLUDED_NORMALS
  #include "/lib/util/Normals.glsl"
#endif

vec2 getRefractionOffset() {
  float strength  = clamp(linearDepth(position.depthBack, near, far) - linearDepth(position.depthFront, near, far), 0.025, 0.025);
        strength /= linearDepth(position.depthFront, near, far) * 0.25;
        strength *= 0.55;

  #ifdef REFRACTION_REALISTIC
    float refractCoeff = (isEyeInWater == 0) ? 1.333 / 1.0003 : 1.0003 / 1.333;

    return -(frontSurface.normal.xy * (refractCoeff * 0.05)) + waterNormal(getWorldPosition(position.viewPositionFront) + cameraPosition).xy * strength;
  #else
    return waterNormal(getWorldPosition(position.viewPositionFront) + cameraPosition).xy * strength;
  #endif
}

vec3 drawRefraction(in vec2 offset) {
  float reprojectedMaterial = texture2D(colortex3, texcoord + offset).b;

  if(
    any(greaterThan(abs((texcoord + offset) - 0.5), vec2(0.5))) ||
    (
      reprojectedMaterial != MATERIAL_WATER
    )
  ) offset = vec2(0.0);

  return toHDR(texture2D(colortex0, clamp01(texcoord + offset)).rgb, COLOUR_RANGE_COMPOSITE);
}
