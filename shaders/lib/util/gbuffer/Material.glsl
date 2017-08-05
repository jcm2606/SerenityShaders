/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

material = 1.0;

#if   SHADER == GBUFFERS_TERRAIN
  material = MATERIAL_TERRAIN;

  if(
    entity.x == SAPLING.x ||
    entity.x == LEAVES1.x ||
    entity.x == LEAVES2.x ||
    entity.x == TALLGRASS.x ||
    entity.x == DEADBUSH.x ||
    entity.x == FLOWER_YELLOW.x ||
    entity.x == FLOWER_RED.x ||
    entity.x == MUSHROOM_BROWN.x ||
    entity.x == MUSHROOM_RED.x ||
    entity.x == WHEAT.x ||
    entity.x == REEDS.x ||
    entity.x == VINE.x ||
    entity.x == LILYPAD.x ||
    entity.x == NETHERWART.x ||
    entity.x == CARROTS.x ||
    entity.x == POTATOES.x ||
    entity.x == DOUBLE_PLANT.x ||
    (
      // Place custom IDs here, replacing 'false'.
      false
    )
  ) material = MATERIAL_FOLIAGE;
#elif SHADER == GBUFFERS_WATER
  material = MATERIAL_TRANSLUCENT;

  if(
    entity.x == WATER.x || entity.x == WATER.y
  ) material = MATERIAL_WATER;

  if(
    entity.x == ICE.x
  ) material = MATERIAL_ICE;

  if(
    entity.x == STAINED_GLASS.x
  ) material = MATERIAL_STAINED_GLASS;
#elif SHADER == GBUFFERS_TEXTURED || SHADER == GBUFFERS_TEXTURED_LIT
  material = MATERIAL_PARTICLE;
#elif SHADER == GBUFFERS_WEATHER
  material = MATERIAL_WEATHER;
#elif SHADER == GBUFFERS_ENTITIES
  material = MATERIAL_ENTITY;
#elif SHADER == GBUFFERS_HAND
  material = MATERIAL_HAND;
#endif