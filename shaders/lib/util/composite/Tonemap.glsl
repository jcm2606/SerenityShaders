/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

const struct Uncharted2Options {
  float A;
  float B;
  float C;
  float D;
  float E;
  float F;
  float W;
};

const Uncharted2Options preset_default = Uncharted2Options(
  /* A */ 0.18,
  /* B */ 0.10,
  /* C */ 0.30,
  /* D */ 0.20,
  /* E */ 0.08,
  /* F */ 0.30, // Contrast
  /* W */ 11.2
);

const Uncharted2Options preset_new = Uncharted2Options(
  /* A */ 0.20,
  /* B */ 0.10,
  /* C */ 0.30,
  /* D */ 0.20,
  /* E */ 0.08,
  /* F */ 0.30, // Contrast
  /* W */ 11.2
);

vec3 uncharted2Equation(const in Uncharted2Options options, in vec3 colour) {
  return ((colour * (options.A * colour + (options.C * options.B)) + options.D * options.E) / (colour * (options.A * colour + options.B) + (options.D * options.F))) - options.E / options.F;
}

vec3 tonemapUncharted2(const in Uncharted2Options options, in vec3 colour) {
  return uncharted2Equation(options, colour) * (vec3(1.0) / uncharted2Equation(options, vec3(options.W)));
}

vec3 tonemap(in vec3 colour) {
  colour *= EXPOSURE;
  colour  = colourSaturation(colour, SATURATION);

  return tonemapUncharted2(
    #ifdef TONEMAP_COMPARISON
      (texcoord.x < sin(frametime) * 0.25 + 0.75 - 0.5) ? preset_default : preset_new,
    #else
      preset_default,
    #endif
    colour
  );
}
