/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#if   STAGE == COMPOSITE2 || STAGE == COMPOSITE3
  #ifndef INCLUDED_NOISE
    #include "/lib/util/Noise.glsl"
  #endif

  #ifndef INCLUDED_SPACE
    #include "/lib/util/Space.glsl"
  #endif

  vec3 cloudMovement = vec3(1.0, 0.0, 0.0) * frametime * 0.07;

  float cloudNoiseOctave(in vec3 pos) {
    float p = floor(pos.z);
    float f = pos.z - p;

    const float noiseResInverse = 1.0 / float(noiseTextureResolution);

    float zStretch = 17.0 * noiseResInverse;

    vec2 coord = pos.xy * noiseResInverse + (p * zStretch);

    float xy1 = texture2D(noisetex, fract(coord)).x;
    float xy2 = texture2D(noisetex, fract(coord) + zStretch).x;

    return mix(xy1, xy2, f);
  }

  float getVolumeCloudNoise(in vec3 rayPos) {
    float cloud = 0.0;

    const vec3 scale = vec3(0.5, 1.0, 0.7) * 0.01;

    rayPos *= scale;

    rayPos.xz *= rot2(windDirection);

    #define octave(size) cloudNoiseOctave(rayPos * size + (cloudMovement * size))

    cloud += cloudNoiseOctave(rayPos * vec3(1.0, 0.1, 1.0) + (cloudMovement * 0.5));
    cloud += octave(2.0) * 0.5;
    cloud += octave(4.0) * 0.25;
    cloud += octave(8.0) * 0.125;
    cloud += octave(16.0) * 0.0625;
    cloud += octave(32.0) * 0.03125;

    #undef octave

    return cloud;
  }

  vec3 vcWorldToView(in vec3 world) {
    //vec4 view = gbufferModelView * vec4(world, 1.0);
    //view /= view.w;
    return transMAD(gbufferModelView, world);
    //return view.xyz;
  }

  #define cloudCoverage3D(x, y, z) clamp01((z + x - 1.0) * y)

  vec4 getVolumeClouds(in vec3 view, in vec2 texcoord, in vec3 direct, in vec3 ambient, in vec4 fog, in int mode) {
    ambient *= 0.15;
    direct *= 2.0;

    vec4 cloud = vec4(0.0);

    const float cloudDepth = VOLUME_CLOUDS_THICKNESS;
    const float cloudLowerHeight = VOLUME_CLOUDS_HEIGHT;
    const float cloudUpperHeight = cloudLowerHeight + cloudDepth;
    const float cloudCenter = cloudDepth * 0.5 + cloudLowerHeight;
    const float cloudDepthHalf = 1.0 / (cloudDepth * 0.5);

    const float cloudCoverageScale = 0.1;
    const float cloudCoverageClear = cloudCoverageScale * 0.42;
    const float cloudCoverageOvercast = cloudCoverageScale * 2.2;
    const float cloudCoverageRain = cloudCoverageScale * 2.4;

    float samples = VOLUME_CLOUDS_SAMPLES;
    float coverage = mix(mix(cloudCoverageClear, cloudCoverageOvercast, clamp01(sin(smoothMoonPhase * pi))), cloudCoverageRain, wetness) * 1.4;
    const float density = 10.0;

    mat4x3 ray;

    vec3 world = getWorldPosition((mode == 0) ? getViewSpacePosition(texcoord, 1.0) : view);

    #define upper      ray[0]
    #define lower      ray[1]
    #define increment  ray[2]
    #define pos        ray[3]

    upper = world * ((cloudUpperHeight - cameraPosition.y) / world.y);
    lower = world * ((cloudLowerHeight - cameraPosition.y) / world.y);

    if(cameraPosition.y < cloudLowerHeight) {
      if(world.y <= 0.0) return cloud;

      swap3(upper, lower);
    } else if(cloudLowerHeight <= cameraPosition.y && cameraPosition.y <= cloudUpperHeight) {
      if(world.y < 0.0) swap3(upper, lower);

      samples *= abs(upper.y) / cloudDepth;
      lower = vec3(0.0);

      swap3(upper, lower);
    } else if(world.y >= 0.0) return cloud;

    increment = (lower - upper) / (1.0 + samples);
    pos = upper + cameraPosition + increment * bayer64(ivec2(int(texcoord.x * viewWidth), int(texcoord.y * viewHeight)));

    coverage *= clamp01(1.0 - flengthsqr((pos.xz - cameraPosition.xz) * 0.0001));

    vec3 lightOffset = fnormalize(getWorldPosition(lightVector));

    float lightAura = pow8(clamp01(dot(fnormalize(view), lightVector) - 0.1));

    lightOffset *= vec3(0.4, 0.1, 0.4);

    vec2 cloudAltitudeWeight = vec2(0.0);
    vec2 cloudFBM = vec2(0.0);

    float cloudFalloff = 0.0;

    float colourWeight = mix(1.0, 0.7, wetness);
    float alphaWeight  = mix(0.8, 0.6, wetness);
    float weight = mix(4.5, 0.2, wetness);

    for(float f = 0.0; f < samples && cloud.a < 1.0; f++, pos += increment) {
      if(mode == 0 && vcWorldToView(pos - cameraPosition).z < view.z && position.depthBack < 1.0) break;

      cloudAltitudeWeight.x = clamp01(distance(pos.y, cloudCenter) * cloudDepthHalf);
      cloudAltitudeWeight.y = clamp01(distance(pos.y + lightOffset.y, cloudCenter) * cloudDepthHalf);

      cloudAltitudeWeight = pow(1.0 - cloudAltitudeWeight, vec2(0.33));

      cloudFBM.x = cloudCoverage3D(coverage, density, getVolumeCloudNoise(pos) * cloudAltitudeWeight.x);

      cloudFBM.x = pow(cloudFBM.x, weight);

      cloudFalloff = lightAura * 0.1 + (pow5((pos.y - cloudLowerHeight) / (cloudDepth - 25.0)) * pow((cloudFBM.x), 1.6));

      cloudFBM.x = (cloudFBM.x / (1.0 + cloudFBM.x)) * alphaWeight;

      cloud.rgb = mix(cloud.rgb, mix(ambient, direct, cloudFalloff) * colourWeight, (1.0 - cloud.a) * cloudFBM.x);

      cloud.a = cloudFBM.x + cloud.a;
    }

    #undef upper
    #undef lower
    #undef step
    #undef pos

    if(mode == 0) cloud.rgb = mix(cloud.rgb, fog.rgb, fog.a);

    return cloud;
  }
#endif

#if STAGE == COMPOSITE3
  vec3 drawVolumeClouds(in vec3 colour, in vec2 texcoord) {
    vec4 cloud = texture2DLod(colortex5, texcoord, 1);

    return mix(colour, cloud.rgb, cloud.a);
  }
#endif
