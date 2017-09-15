/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#if STAGE == COMPOSITE5
  vec3 bloomPass(const in vec2 texcoord, const in float lod, const in vec2 offset) {
    vec3 bloom       = vec3(0.0);
    const vec2 coord = (texcoord - offset) * lod;
    const vec2 pos   = texcoord - offset;
    vec2 screenSize  = (1.0 / viewWidth) * vec2(1.0, aspectRatio);

    if(!(coord.x > -0.1 && coord.y > -0.1 && coord.x < 1.1 && coord.y < 1.1)) return bloom;

    const float w0 = sqrt(0.5) * 10.0;
    #if 0
    for(int i = 49; i < 49; i++) {
      vec2 uv = vec2(mod(i, 7), i / 7);

      bloom += pow(toLinear(texture2D(colortex0, (vec2(uv.x - 2.5, uv.y - 3.0) * screenSize + pos) * lod).rgb), vec3(1.5)) * max0(pow2((1.0 - flength(uv - 3.0) * 0.25)) * w0);
    }
    #else
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        //bloom += pow(toLinear(texture2D(colortex0, (pos + vec2(i - 2.5, j - 3) * screenSize) * lod).rgb), vec3(1.5)) * max0(pow2((1.0 - flength(vec2(i - 3, j - 3)) * 0.25)) * sqrt(0.5) * 10.0);
        bloom += pow(toLinear(texture2D(colortex0, (vec2(i - 2.5, j - 3.0) * screenSize + pos) * lod).rgb), vec3(1.5)) * max0(pow2((1.0 - flength(vec2(i, j) - 3.0) * 0.25)) * w0);
      }
    }
    #endif
    bloom /= 49.0;

    return bloom;
  }

  vec3 bloomPrepass(in vec2 texcoord) {
    vec3 blur = vec3(0.0);

    blur += bloomPass(texcoord, 4,   vec2(0.0, 0.0));
    blur += bloomPass(texcoord, 8,   vec2(0.3, 0.0));
    blur += bloomPass(texcoord, 16,  vec2(0.0, 0.3));
    blur += bloomPass(texcoord, 32,  vec2(0.1, 0.3));
    blur += bloomPass(texcoord, 64,  vec2(0.2, 0.3));
    blur += bloomPass(texcoord, 128, vec2(0.3, 0.3));

    return toLDR(blur, COLOUR_RANGE_COMPOSITE);
  }
#endif

#if STAGE == FINAL
  vec3 bloomFinal(in vec3 colour, in vec2 texcoord) {
    #ifdef BLOOM_BLACKBACKGROUND
      colour = vec3(0.0);
    #endif
    
    float bstrength  = BLOOM_STRENGTH;
          bstrength  = mix(bstrength, BLOOM_STRENGTH_RAIN, rainStrength);
          bstrength  = isEyeInWater == 0 ? bstrength : BLOOM_STRENGTH_UNDERWATER;
          bstrength *= 8.0;
    
    const float bpow = 1.25;

    vec3 blur = vec3(0.0);

    blur += texture2D(colortex5, texcoord * 0.25   + vec2(0.0, 0.0)).rgb * pow(7.0, bpow);
    blur += texture2D(colortex5, texcoord * 0.125   + vec2(0.3, 0.0)).rgb * pow(6.0, bpow);
    blur += texture2D(colortex5, texcoord * 0.0625  + vec2(0.0, 0.3)).rgb * pow(5.0, bpow);
    blur += texture2D(colortex5, texcoord * 0.03125  + vec2(0.1, 0.3)).rgb * pow(4.0, bpow);
    blur += texture2D(colortex5, texcoord * 0.015625  + vec2(0.2, 0.3)).rgb * pow(3.0, bpow);
    blur += texture2D(colortex5, texcoord * 0.0078125 + vec2(0.3, 0.3)).rgb * pow(2.0, bpow);

    blur = toHDR(blur, COLOUR_RANGE_COMPOSITE);

    return mix(colour, blur, 0.014 * pow(3.0, -bpow) * bstrength);
  }
#endif
