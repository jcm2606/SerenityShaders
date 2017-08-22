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

  // SAMPLE
  float distx(in float dist){
    return (far * (dist - near)) / (dist * (far - near));
  }

  // FOG
  float getMoisture(in vec3 world, in vec3 view) {
    float moisture = 0.0;

    // HEIGHT FOG
    moisture += mix(0.01, 0.5, clamp01(exp2(-max0(world.y - MC_SEA_LEVEL) * 0.01)));

    // GROUND FOG
    moisture += mix(0.0, 4.0, clamp01(exp2(-max0(world.y - MC_SEA_LEVEL) * 0.4)));

    return moisture * 0.0009;
  }

  // MARCHER
  void getFog(inout vec4 fogOut, in vec3 direct, in vec3 ambient) {
    fogOut = vec4(0.0);

    const int steps = FOG_QUALITY;
    const float inverseSteps = 1.0 / float(steps);
    const float finalMultiplier = inverseSteps * 15.0;
    
    mat4 worldToShadow = shadowProjection * shadowModelView;
    mat4 shadowToWorld = shadowModelViewInverse * shadowProjectionInverse;

    mat2x3 fog = mat2x3(0.0);

    #define lightColour fog[0]
    #define occlusion fog[1].x
    #define moisture fog[1].y

    mat4x3 ray = mat4x3(0.0);

    #define rayStart ray[0]
    #define rayEnd ray[1]
    #define rayPos ray[2]
    #define rayStep ray[3]

    rayStart = transMAD(worldToShadow, getWorldPosition(vec3(0.0, 0.0, 0.0)));
    rayEnd = transMAD(worldToShadow, getWorldPosition(position.viewPositionBack));

    rayStep = fnormalize(rayEnd - rayStart) * distance(rayEnd, rayStart) * inverseSteps;

    rayPos = rayStep * bayer64(ivec2(int(texcoord.x * viewWidth), int(texcoord.y * viewHeight))) + rayStart;

    mat3x3 positions = mat3x3(0.0);
    mat3x4 shadowBuffer = mat3x4(0.0);

    #define shadow positions[0]
    #define world positions[1]
    #define view positions[2]

    #define shadowColour shadowBuffer[0].rgb
    #define depthFront shadowBuffer[1].x
    #define shadowFront shadowBuffer[1].y
    #define shadowBack shadowBuffer[1].z
    #define material shadowBuffer[1].w

    float weight = pow(flength(rayStep), 0.4);

    for (int i = 0; i < steps; i++, rayPos += rayStep) {
      shadow = vec3(distortShadowPosition(rayPos.xy, 0), rayPos.z) * 0.5 + 0.5;
      world = transMAD(shadowToWorld, rayPos);
      view = transMAD(gbufferModelView, world);
      world += cameraPosition;

      depthFront = texture2D(shadowtex0, shadow.xy).x;
      shadowFront = compareShadow(depthFront, shadow.z);
      shadowBack = (!getLandMask(position.depthBack)) ? 1.0 : compareShadow(texture2D(shadowtex1, shadow.xy).x, shadow.z);
      material = texture2D(shadowcolor1, shadow.xy).a;
      shadowColour = vec3(1.0);

      lightColour += shadowColour * weight;// * ((isWithinThreshold(material, MATERIAL_WATER, 0.01) > 0.5) ? absorbWater(abs(shadowDepth - shadow.z) * 256.0) : 1.0); 
      moisture += getMoisture(world, view) * weight;
      occlusion += shadowBack * weight;
    }

    #undef shadow
    #undef world
    #undef view

    #undef shadowColour
    #undef depthFront
    #undef shadowFront
    #undef shadowBack
    #undef material

    // CYCLE FOG
    moisture += max0(sin(smoothMoonPhase * pi)) * 0.009;

    // RAIN FOG
    moisture += wetness * 0.007;

    fogOut.a = occlusion * moisture;

    fogOut.rgb = lightColour * (
      direct * FOG_LIGHTING_DIRECT_CONTRIBUTION * max(0.05, pow5(dot(normalize(position.viewPositionBack), lightVector))) +
      ambient * FOG_LIGHTING_AMBIENT_CONTRIBUTION
    );

    fogOut *= finalMultiplier;

    fogOut.rgb = toLDR(fogOut.rgb, COLOUR_RANGE_FOG);
    fogOut.a = pow(fogOut.a, inverseGammaCurve);

    #undef occlusion
    #undef moisture

    #undef rayStart
    #undef rayEnd
    #undef rayPos
    #undef rayStep
  }

  /*
  float getFog(inout vec3 outColour, in vec3 direct, in vec3 ambient) {
    vec2 ray = vec2(0.0);

    #define rayStrength ray.x
    #define rayDither   ray.y

    const float rayStep = 12.0 / FOG_QUALITY;
    rayDither  = bayer64(ivec2(int(texcoord.x * viewWidth), int(texcoord.y * viewHeight)));
    rayDither *= rayStep;

    const float maxDist  = FOG_DISTANCE;
    const float weight   = 1.0 / (maxDist / rayStep) * maxDist;
    float minDist  = 0.001;
          minDist += rayDither;

    vec3 colour = vec3(0.0);
    int colourSamples = 0;

    vec4 fogVector = vec4(0.0);

    #define shadowFront fogVector.x
    #define shadowBack  fogVector.y
    #define shadowDepth fogVector.z
    #define moisture    fogVector.w

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
      shadowBack = (compareShadow(texture2D(shadowtex1, shadowPosition.xy).x, shadowPosition.z));

      if(shadowBack > 0.0) {
        // SAMPLE FRONT SHADOW DEPTH
        shadowDepth = texture2DLod(shadowtex0, shadowPosition.xy, 0).x;

        // GENERATE FRONT SHADOW OCCLUSION
        shadowFront = (compareShadow(shadowDepth, shadowPosition.z));

        // SAMPLE MATERIAL FROM AUXILIARY SHADOW MAP
        material = texture2D(shadowcolor1, shadowPosition.xy).a;

        // SAMPLE SHADOW COLOUR
        colourSample = (shadowBack - shadowFront > 0.0) ? toHDR(texture2D(shadowcolor0, shadowPosition.xy).rgb, COLOUR_RANGE_SHADOW) : vec3(1.0);

        // PERFORM WATER ABSORPTION FOR WATER
        if(shadowBack - shadowFront > 0.0 && isWithinThreshold(material, MATERIAL_WATER, 0.01) > 0.5) colourSample *= absorbWater(abs(shadowDepth - shadowPosition.z) * 256.0);

        // TINT FOG IF FOG IS BEHIND TRANSPARENT SURFACE
        colourSample *= (any(greaterThan(frontSurface.albedo, vec3(0.0))) && linearDepth(position.depthFront, near, far) < minDist) ? frontSurface.albedo : vec3(1.0);
        
        // ADD TO COLOUR
        colour += colourSample;

        // INCREMENT COLOUR SAMPLES
        colourSamples++;

        // GENERATE MOISTURE
        moisture = getMoisture(minDist, worldPosition, material, shadowBack, shadowFront) + moisture;

        // INCREASE THE STRENGTH OF THE RAY
        rayStrength = shadowBack + rayStrength;
      }
    }

    // WEIGHTS AND DISTANCE SCALING
    colour /= colourSamples;
    colour *= maxDist;
    colour *= 0.015;

    rayStrength *= weight;
    moisture *= weight;

    // TIME-BASED MOISTURE SCALING
    moisture += FOG_THICKNESS_NOON * timeVector.x + FOG_THICKNESS_NIGHT * timeVector.y + mix(FOG_THICKNESS_SUNSET, FOG_THICKNESS_SUNRISE, timeVector.w) * timeVector.z;

    // CYCLE-BASED MOISTURE SCALING
    moisture += max0(sin(smoothMoonPhase * pi)) * 96.0;

    // RAIN MOISTURE SCALING
    moisture += wetness * 64.0;

    // LIGHTING CONTRIBUTION
    outColour = (
      direct * FOG_DIRECT_CONTRIBUTION * ( pow(max0(dot(normalize(position.viewPositionBack), lightVector)), FOG_DIRECT_ANISOTROPY) * 2.0 + 1.0 ) / max(1.0, moisture * 0.05) +
      ambient * FOG_AMBIENT_CONTRIBUTION
    );

    // COLOURED SHADOW APPLICATION
    outColour *= (any(greaterThan(colour, vec3(0.0)))) ? colour : vec3(1.0);

    // CONVERT OUTPUTS TO LDR
    outColour   = toLDR(outColour, COLOUR_RANGE_FOG);
    //rayStrength = pow(rayStrength / COLOUR_RANGE_FOG, inverseGammaCurve);

    return rayStrength * moisture * 0.3E-4;

    #undef shadowFront
    #undef shadowBack
    #undef shadowDepth
    #undef moisture

    #undef rayStrength
    #undef rayStep
    #undef rayDither
  }
  */
#elif STAGE == COMPOSITE2
  vec3 drawFog(in vec3 colour, in vec2 texcoord, in vec2 refractOffset) {
    // SAMPLE THE FOG WITH A 3x3 DEPTH AWARE BOX BLUR
    const int samples = 3;
    const float blurWidth = 0.002 / samples;
    const float threshold = 0.001;
    int blurIterations = 0;

    vec4 fog = vec4(0.0);

    float refractCondition = min1(isEyeInWater * frontMaterial.water + (frontMaterial.ice + frontMaterial.stainedGlass));

    for(int i = -samples; i <= samples; i++) {
      for(int j = -samples; j <= samples; j++) {
        if(texture2D(depthtex1, vec2(i, j) * blurWidth + texcoord).x - position.depthBack > threshold) continue;

        fog += texture2DLod(colortex5, refractOffset * refractCondition + (vec2(i, j) * blurWidth + texcoord), 1);

        blurIterations++;
      }
    }

    fog /= blurIterations;

    //return toHDR(fog.rgb, COLOUR_RANGE_FOG) * clamp01(pow(fog.a, gammaCurve)) + colour;
    return mix(colour, toHDR(fog.rgb, COLOUR_RANGE_FOG), clamp01(pow(fog.a, gammaCurve)));
  }
#endif
