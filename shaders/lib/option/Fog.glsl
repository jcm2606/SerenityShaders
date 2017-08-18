/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define VOLUMETRIC_FOG

#define FOG_QUALITY  2.0 // [1.0 2.0 3.0 4.0 5.0]
#define FOG_DISTANCE 64.0

// LIGHTING OPTIONS
#define FOG_DIRECT_MINIMUM 0.3
#define FOG_DIRECT_ANISOTROPY 6.0
#define FOG_DIRECT_CONTRIBUTION 1.0

#define FOG_AMBIENT_CONTRIBUTION 1.0

#define FOG_BRIGHTNESS_NIGHT 2.0

// FOG OPTIONS
#define FOG_THICKNESS_NOON      0.0 // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define FOG_THICKNESS_NIGHT     20.0 // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define FOG_THICKNESS_SUNRISE   10.0 // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define FOG_THICKNESS_SUNSET    5.0 // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]

#define FOG_HEIGHT
#define FOG_HEIGHT_MIN            0.005
#define FOG_HEIGHT_MULTIPLIER     0.01
#define FOG_HEIGHT_THICKNESS_HIGH 1.0
#define FOG_HEIGHT_THICKNESS_MID  0.5
#define FOG_HEIGHT_THICKNESS_LOW  0.5

#define FOG_GROUND
#define FOG_GROUND_HQ
#define FOG_GROUND_HEIGHT            0.5
#define FOG_GROUND_THICKNESS         0.14
