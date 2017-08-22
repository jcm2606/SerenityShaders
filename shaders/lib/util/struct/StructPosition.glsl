/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_POSITION

#define POSITION Position(0.0, 0.0, vec3(0.0), vec3(0.0))

struct Position {
  float depthBack;
  float depthFront;

  vec3 viewPositionBack;
  vec3 viewPositionFront;
};

void createDepths(inout Position position, in vec2 texcoord) {
  position.depthBack = texture2D(depthtex1, texcoord).x;
  position.depthFront = texture2D(depthtex0, texcoord).x;
}
