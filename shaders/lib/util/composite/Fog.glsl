/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#if   STAGE == COMPOSITE1
  #ifndef INCLUDED_NOISE
    #include "/lib/util/Noise.glsl"
  #endif

  // FOG
  float getHeightFog(in vec3 world) {
    float fog = 0.0;

    fog += mix(
      0.0,
      FOG_HEIGHT_THICKNESS_HIGH,
      clamp01(exp2(-max0(world.y - MC_SEA_LEVEL) * 0.05))
    );

    fog += mix(
      0.0,
      FOG_HEIGHT_THICKNESS_MID,
      clamp01(exp2(-max0(world.y - MC_SEA_LEVEL) * 0.1))
    );

    fog += mix(
      0.0,
      FOG_HEIGHT_THICKNESS_LOW,
      clamp01(exp2(-max0(world.y - MC_SEA_LEVEL) * 0.2))
    );

    return max(FOG_HEIGHT_MIN, fog * FOG_HEIGHT_MULTIPLIER);
  }

  float getGroundFog(in vec3 world) {
    #define scale 1.0E-1
    #define stretch vec3(1.0, 2.0, 1.0)

    vec3 move = vec3(1.0, 0.0, 0.0) * frametime * 0.1;

    #define rot(a) mat2(cos(a), -sin(a), sin(a), cos(a))
    world.xz *= rot(0.7);
    #undef rot

    float noise  = max0(simplex3D(world * stretch * scale + move));
          noise += max0(simplex3D(world * stretch * scale * 2.0 + move * 4.0));

    #undef scale
    #undef stretch

    return mix(0.0, FOG_GROUND_THICKNESS, clamp01(
      exp2(-abs(world.y - MC_SEA_LEVEL) * FOG_GROUND_HEIGHT) * noise
    ));
  }

  float getWaterFog(in float minDist) {
    return ((isEyeInWater == 1 && linearDepth(position.depthFront, near, far) > minDist)) ? 0.1 : 0.1;
  }

  // SAMPLE
  float distx(in float dist){
    return (far * (dist - near)) / (dist * (far - near));
  }

  float getFog(inout vec3 outColour, in vec3 direct, in vec3 ambient) {
    vec2 ray = vec2(0.0);

    #define rayStrength ray.x
    #define rayDither   ray.y

    const float rayStep = 12.0 / FOG_QUALITY;
    rayDither  = bayer64(ivec2(int(texcoord.x * viewWidth), int(texcoord.y * viewHeight)));
    rayDither *= rayStep;

    const float maxDist  = FOG_DISTANCE;
    const float weight   = 1.0 / (maxDist / rayStep);
    float minDist  = 0.001;
          minDist += rayDither;

    vec3 colour = vec3(0.0);
    int colourSamples = 0;

    vec3 shadowVector = vec3(0.0);
    float fog         = 0.0;

    #define shadowFront shadowVector.x
    #define shadowBack  shadowVector.y
    #define shadowDepth shadowVector.z

    vec3 shadowPosition = vec3(0.0);
    vec3 worldPosition  = vec3(0.0);

    float material = 0.0;
    vec3 colourSample = vec3(0.0);

    for(minDist; minDist < maxDist; minDist += rayStep) {
      // STOP SAMPLING WHEN THE RAY INTERSECTS AN OBJECT
      if(linearDepth(position.depthBack, near, far) < minDist) break;

      // CONVERT RAY INTO WORLD POSITION
      worldPosition = getWorldPosition(getViewSpacePosition(texcoord, distx(minDist)));

      // CONVERT RAY INTO SHADOW POSITION
      shadowPosition = getShadowPosition(worldPosition);
      shadowPosition = distortShadowPosition(shadowPosition, 1);

      worldPosition += cameraPosition;

      // SAMPLE BACK SHADOW OCCLUSION
      shadowBack = ceil(compareShadow(texture2D(shadowtex1, shadowPosition.xy).x, shadowPosition.z));

      if(shadowBack > 0.0) {
        // SAMPLE FRONT SHADOW DEPTH
        shadowDepth = texture2DLod(shadowtex0, shadowPosition.xy, 0).x;

        // GENERATE FRONT SHADOW OCCLUSION
        shadowFront = ceil(compareShadow(shadowDepth, shadowPosition.z));

        // SAMPLE MATERIAL FROM AUXILIARY SHADOW MAP
        material = texture2D(shadowcolor1, shadowPosition.xy).a;

        // SAMPLE SHADOW COLOUR
        colourSample = (shadowBack - shadowFront > 0.0) ? toHDR(texture2D(shadowcolor0, shadowPosition.xy).rgb, COLOUR_RANGE_SHADOW) : vec3(1.0);

        // PERFORM WATER ABSORPTION FOR WATER
        if(shadowBack - shadowFront > 0.0 && isWithinThreshold(material, MATERIAL_WATER, 0.01) > 0.5) colourSample *= absorbWater(abs(shadowDepth - shadowPosition.z) * 256.0);
        
        // ADD TO COLOUR
        colour += colourSample;

        // INCREMENT COLOUR SAMPLES
        colourSamples++;

        // GENERATE FOG
        // HEIGHT FOG
        fog  = getHeightFog(worldPosition);

        // GROUND FOG
        fog += getGroundFog(worldPosition);

        // WATER FOG
        if(shadowBack - shadowFront > 0.0 && isWithinThreshold(material, MATERIAL_WATER, 0.01) > 0.5 && shadowPosition.z > shadowDepth) fog += 0.01;

        // INCREASE THE STRENGTH OF THE RAY
        rayStrength = shadowBack * fog + rayStrength;
      }
    }

    //colourSamples = 1; // TODO: Remove this when I add coloured VL.
    colour /= colourSamples;
    colour *= maxDist;
    colour *= 0.015;

    rayStrength *= weight;
    rayStrength *= maxDist;
    rayStrength *= FOG_THICKNESS_NOON * timeVector.x + FOG_THICKNESS_NIGHT * timeVector.y + mix(FOG_THICKNESS_SUNSET, FOG_THICKNESS_SUNRISE, timeVector.w) * timeVector.z;

    outColour = vec3(mix(1.0, FOG_BRIGHTNESS_NIGHT, timeVector.y)) * (
      direct * FOG_DIRECT_CONTRIBUTION * max(FOG_DIRECT_MINIMUM, pow(max0(dot(fnormalize(position.viewPositionBack), lightVector) * 0.5 + 0.5), FOG_DIRECT_ANISOTROPY)) +
      ambient * FOG_AMBIENT_CONTRIBUTION
    );

    outColour *= (any(greaterThan(colour, vec3(0.0)))) ? colour : vec3(1.0);

    outColour *= (any(greaterThan(frontSurface.albedo, vec3(0.0)))) ? frontSurface.albedo : vec3(1.0);

    outColour   = toLDR(outColour, COLOUR_RANGE_FOG);
    rayStrength = pow(rayStrength / COLOUR_RANGE_FOG, inverseGammaCurve);

    return rayStrength;

    #undef shadowFront
    #undef shadowBack
    #undef shadowDepth

    #undef rayStrength
    #undef rayStep
    #undef rayDither
  }
#elif STAGE == COMPOSITE2
  vec3 drawFog(in vec3 colour, in vec2 texcoord, in vec2 refractOffset) {
    // SAMPLE THE FOG WITH A 3x3 DEPTH AWARE BOX BLUR
    const int samples = 3;
    const float blurWidth = 0.002 / samples;
    const float threshold = 0.001;
    int blurIterations = 0;

    vec4 fog = vec4(0.0);

    float refractCondition = isEyeInWater * frontMaterial.water;

    for(int i = -samples; i <= samples; i++) {
      for(int j = -samples; j <= samples; j++) {
        if(texture2D(depthtex1, vec2(i, j) * blurWidth + texcoord).x - position.depthBack > threshold) continue;

        fog += texture2DLod(colortex5, refractOffset * refractCondition + (vec2(i, j) * blurWidth + texcoord), 0);

        blurIterations++;
      }
    }

    fog /= blurIterations;

    return toHDR(fog.rgb, COLOUR_RANGE_FOG) * (pow(fog.a, gammaCurve)) * COLOUR_RANGE_FOG + colour;
  }
#endif
