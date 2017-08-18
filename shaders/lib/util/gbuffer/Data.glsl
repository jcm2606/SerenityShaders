// NORMAL MAP
#if   SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_HAND
  vec4 normalMap = texture2D(normals, uvcoord);
#else
  vec4 normalMap = vec4(0.0);
#endif

// PUDDLES
#if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_ENTITIES
  float puddle = getPuddles(worldpos, lmcoord.y, normalMap.a);
#endif

// ALBEDO
vec4 albedo = vec4(0.0);

#if SHADER == GBUFFERS_TERRAIN
  albedo = texture2D(texture, uvcoord) * colour;
#elif SHADER == GBUFFERS_ENTITIES || SHADER == GBUFFERS_HAND || SHADER == GBUFFERS_SKYTEXTURED || SHADER == GBUFFERS_CLOUD || SHADER == GBUFFERS_TEXTURED || SHADER == GBUFFERS_TEXTUREDLIT
  albedo = texture2D(texture, uvcoord) * colour;
#elif SHADER == GBUFFERS_WATER
  albedo = texture2D(texture, uvcoord) * colour;

  if(material == MATERIAL_WATER) albedo = vec4(0.0);
#elif SHADER == GBUFFERS_SKYBASIC
  albedo = colour;
#elif SHADER == GBUFFERS_WEATHER
  albedo = vec4(vec3(0.8, 0.85, 0.9), texture2D(texture, uvcoord).a);
#endif

#if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_ENTITIES
  //albedo.rgb = vec3(puddle);
#endif

buffer0.r = encodeColor(albedo.rgb);

// LIGHTMAP
buffer0.g = encodeLightMap(lmcoord);

// MATERIAL
buffer0.b = material;

// NORMAL
vec3 surfaceNormal = normal;

#if   SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_HAND
  float normalMaxAngle = mix(0.5, 0.0, puddle);
  //normalMaxAngle = normalMaxAngle * (1.0 - wetness * lmcoord.y * 0.65);

  surfaceNormal  = normalMap.rgb * 2.0 - 1.0;
  surfaceNormal  = surfaceNormal * vec3(normalMaxAngle) + vec3(0.0, 0.0, 1.0 - normalMaxAngle);
  surfaceNormal *= tbn;
  surfaceNormal  = fnormalize(surfaceNormal);
#elif SHADER == GBUFFERS_WATER
  const float normalMaxAngle = 0.03;

  surfaceNormal  = getNormal(getTransparentParallax(worldpos, view, material), material);
  surfaceNormal  = surfaceNormal * vec3(normalMaxAngle) + vec3(0.0, 0.0, 1.0 - normalMaxAngle);
  surfaceNormal *= tbn;
  surfaceNormal  = fnormalize(surfaceNormal);
#endif

buffer1.r = encodeNormal(vec3(surfaceNormal));

// PBR INFO
float roughness = 0.0;
float f0 = 0.0;
float emissive = 0.0;

#if   SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_HAND
  vec4 surfaceSpecular = texture2D(specular, uvcoord);

  getFallbackPBR(entity, roughness, f0, emissive);

  #if   RESOURCE_FORMAT == 1
    // SPECULAR
    roughness = 1.0 - surfaceSpecular.r;
  #elif RESOURCE_FORMAT == 2
    // OLD PBR
    roughness = 1.0 - surfaceSpecular.r;
    f0 = mix(0.02, 0.8, surfaceSpecular.g);
  #elif RESOURCE_FORMAT == 3
    // OLD PBR WITH EMISSIVE
    roughness = 1.0 - surfaceSpecular.r;
    f0 = mix(0.02, 0.8, surfaceSpecular.g);
    emissive = surfaceSpecular.b;
  #elif RESOURCE_FORMAT == 4
    // NEW PBR
    roughness = 1.0 - surfaceSpecular.b;
    f0 = surfaceSpecular.r;
    emissive = 1.0 - surfaceSpecular.a;
  #endif
#elif SHADER == GBUFFERS_ENTITIES
  roughness = 0.8;
  f0 = 0.02;
  emissive = 0.0;
#elif SHADER == GBUFFERS_WATER
  getFallbackPBR(entity, roughness, f0, emissive);
#endif

#if SHADER == GBUFFERS_TERRAIN || SHADER == GBUFFERS_ENTITIES
#if 1
  roughness = mix(roughness, PBR_WATER.x, puddle);
  f0 = (f0 >= 0.5) ? f0 : mix(f0, PBR_WATER.y, puddle);
  emissive = mix(emissive, PBR_WATER.z, puddle);
#endif
#endif

buffer1.g = encodeLightMap(vec2(roughness, f0));
buffer1.b = encodeLightMap(vec2(emissive, 0.0));

// HANDLING ALPHA
#if SHADER == GBUFFERS_WATER
  buffer0.a = 1.0;
#elif SHADER == GBUFFERS_TEXTURED || SHADER == GBUFFERS_TEXTUREDLIT || SHADER == GBUFFERS_HAND || SHADER == GBUFFERS_WEATHER
  buffer0.a = sign(albedo.a);
#else
  buffer0.a = albedo.a;
#endif

buffer1.a = buffer0.a;
