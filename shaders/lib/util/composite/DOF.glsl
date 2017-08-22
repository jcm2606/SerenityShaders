/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

vec2 bokeh(in float point, const in float rings, const in float pointScale, const in float bladeScale, const in float tauScale, const in float piScale) {
  point *= tauScale;

  return mix(pointScale, DOF_STRENGTH, pow(abs(cos((point * BLADE_ROTATION_STRENGTH / (rings * DOF_SAMPLES)) * DOF_RINGS * piScale)), bladeScale)) * 2.0 * vec2(cos(point), sin(point)) * rings;
}

vec3 doDOF(in float depth) {
  float colourCorrection = 1.0;

  const float bladeScale = 16.0 - BLADES;
  const float pointScale = pow(cos(pi / BLADES), 1.0 - BLADE_ROUNDING);
  const float tauScale = tau / DOF_SAMPLES;
  const float piScale = pi * BLADES;

  const float fStop = 0.9;
  const float focalLength = 45.0;
  const float focalLengthMM = focalLength * 0.001;
  const float aperture = 0.1;

  float linearFocusPoint = linearDepth(centerDepthSmooth, near, far);
  float linearPixelDepth = linearDepth(centerDepthSmooth, near, far);

  float focus = aperture * (focalLengthMM * (linearFocusPoint - linearPixelDepth)) / (linearFocusPoint * (linearPixelDepth - focalLengthMM));

  focus = (depth - centerDepthSmooth) * (aperture - focus) / fStop + focus;

  #ifdef TILT_SHIFT
    focus = (texcoord.y - 0.5) * 0.01;
  #endif

  float focusMax = focalLengthMM * aperture;

  focus = clamp(focus, -focusMax, focusMax);

  focus = (aperture - focalLengthMM) / focalLengthMM * focus;

  float LOD = abs(focus) / ((aperture / focalLength) * fStop) * 0.75;

  const vec3 dispersion = vec3(0.8, 1.0, 1.2);

  focus *= DOF_STRENGTH / (1.0 + DOF_RINGS);

  focus = (isEyeInWater == 0) ? focus : focusMax * 0.5;

  vec2 focusCircle = focus * vec2(1.0, aspectRatio);

  vec4 blurredSample = vec4(0.0);

  for(int i = 0; i < 1.0 + DOF_RINGS; i++) {
    for(int j = 0; j < i * DOF_SAMPLES; j++) {
      vec2 bokehPoints = bokeh(j, i, pointScale, bladeScale, tauScale, piScale) * focusCircle;

      blurredSample.r += (texture2DLod(colortex0, bokehPoints * dispersion.x + texcoord, LOD).r);
      blurredSample.g += (texture2DLod(colortex0, bokehPoints * dispersion.y + texcoord, LOD).g);
      blurredSample.b += (texture2DLod(colortex0, bokehPoints * dispersion.z + texcoord, LOD).b);

      colourCorrection++;
    }
  }

  return toHDR(blurredSample.rgb / colourCorrection, COLOUR_RANGE_COMPOSITE);
}