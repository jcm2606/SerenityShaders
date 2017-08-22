/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_MACROS

#define max0(n) max(0.0, n)
#define min1(n) min(1.0, n)
#define clamp01(n) clamp(n, 0.0, 1.0)

#define selectSurface() ((position.depthBack > position.depthFront) ? frontSurface : backSurface)
#define selectMaterial() ((position.depthBack > position.depthFront) ? frontMaterial : backMaterial)

#define getLandMask(x) (x < (1.0 - near / far / far))

#define random(x) fract(sin(dot(x, vec2(12.9898, 4.1414))) * 43758.5453)

#define smoothMoonPhase ( (float(worldTime) + float(moonPhase) * 24000.0) * 0.00000595238095238 )

#define compareValues2(a,b,t) ((t.x > 0.5) ? a : b)
