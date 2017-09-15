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
  float strength  = 0.02;
        strength /= linearDepth(position.depthFront, near, far) * 0.25;

  #ifdef REFRACTION_REALISTIC
    return getNormal(getWorldPosition(position.viewPositionFront) + cameraPosition, frontSurface.material).xy * strength - (frontSurface.normal.xy * ((isEyeInWater == 0) ? 0.039978 : 0.022512378));
  #else
    return getNormal(getWorldPosition(position.viewPositionFront) + cameraPosition, frontSurface.material).xy * strength;
  #endif
}

vec3 drawRefraction(in vec2 offset) {
  float reprojectedMaterial = texture2D(colortex3, texcoord + offset).b;

  if(
    any(greaterThan(abs((texcoord + offset) - 0.5), vec2(0.5))) ||
    (
      reprojectedMaterial != frontSurface.material
    )
  ) offset = vec2(0.0);

  return toHDR(texture2D(colortex0, clamp01(offset + texcoord)).rgb, COLOUR_RANGE_COMPOSITE);
}
