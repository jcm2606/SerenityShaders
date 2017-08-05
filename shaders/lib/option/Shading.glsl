// LIGHTING
#define DIRECT_MOONLIGHT_COLOUR_OPTION 0 // [0]

#define DIRECT_MOONLIGHT_SATURATION 0.3

#if DIRECT_MOONLIGHT_COLOUR_OPTION == 0
  vec3 moonlight = colourSaturation(vec3(0.0, 0.0, 1.0), DIRECT_MOONLIGHT_SATURATION);
#endif

#define DIRECT_BRIGHTNESS_NOON    0.008
#define DIRECT_BRIGHTNESS_NIGHT   0.006
#define DIRECT_BRIGHTNESS_HORIZON 0.006

#define BLOCK_COLOUR_OPTION 0 // [0]
#define BLOCK_ATTENUATION 8.0
#define BLOCK_BRIGHTNESS 3.0

#if BLOCK_COLOUR_OPTION == 0
  const vec3 blockLight = vec3(0.9, 0.5, 0.1);
#endif

#define AMBIENT_BRIGHTNESS 4.0

#define AMBIENT_ATTENUATION 4.0

// SHADING
#define SHADOW_BIAS 0.9

const int shadowMapResolution = 2048; // [1024 2048 4096]
const float shadowDistance = 120.0;
const float shadowDistanceRenderMul = 1.0E-10;

#define SHADOW_PENUMBRA_QUALITY 2 // [1 2 3 4 5 6]
