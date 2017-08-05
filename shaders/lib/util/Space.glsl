/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_SPACE

float fovScale = gbufferProjection[1][1] * tan(atan(1.0 / gbufferProjection[1][1]) * 0.85);

vec3 getViewSpacePosition(in vec2 texcoord, in float depth) {
  vec4 vpos = projMAD4(gbufferProjectionInverse, (vec3(texcoord, depth) * 2.0 - 1.0).xyzz);
  vpos /= vpos.w;

  if(isEyeInWater == 1) vpos.xy *= fovScale;

  return vpos.xyz;
}

vec3 getScreenSpacePosition(in vec3 view) {
  vec4 screen  = gbufferProjection * vec4(view, 1.0);
       screen /= screen.w;
       screen  = screen * 0.5 + 0.5;

  return screen.xyz;
}

vec3 getWorldPosition(in vec3 view) {
  return transMAD(gbufferModelViewInverse, view);
}

#ifdef INCLUDED_POSITION
  void createViewPositions(inout Position position, in vec2 texcoord, in bool front, in bool back) {
    if(front) position.viewPositionFront = getViewSpacePosition(texcoord, position.depthFront);
    if(back)  position.viewPositionBack  = getViewSpacePosition(texcoord, position.depthBack);
  }
#endif
