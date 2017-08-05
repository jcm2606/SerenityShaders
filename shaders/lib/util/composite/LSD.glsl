vec3 drawLSDMode(in vec2 texcoord) {
  vec3 colour = vec3(0.0);
 
  mat3x2 coords = mat3x2(
    texcoord,
    texcoord,
    texcoord
  );

  #define coordstep(c,s) (c * s + (1.0 - s))

  coords[0] *= coordstep(sin(flength(coords[0] * 2.0 - 1.0) * 0.75 * pi), 0.0625);
  coords[2] *= coordstep(cos(flength(coords[2] * 2.0 - 1.0) * flength(coords[0] * 0.5 + 0.5) * pi + frametime * pi * .4), 0.0625);
  //coords[1] *= 1.0 - sin(-flength(coords[1] * 2.0 - 1.0) + frametime * 0.25) * 0.03125 + sin(frametime * 2.0 * sin(pi));
  //coords[2] *= 1.0 - sin(flength(coords[2] * 2.0 - 1.0) * 2.0 * pi + frametime * 1.0) * 0.03125;

  /*
  coords[0] *= sin((coords[0] * 2.0 - 1.0) + 0.07 * frametime * -pi);
  coords[0] = mix(coords[0], texcoord, 0.75);

  coords[2] *= cos((coords[2] * 0.5 + 0.5) + 0.06 * -frametime * pi);
  coords[2] = mix(coords[2], texcoord, 0.75);
  */
  colour.r = texture2D(colortex0, coords[0]).r;
  colour.g = texture2D(colortex0, coords[1]).g;
  colour.b = texture2D(colortex0, coords[2]).b;

  return toHDR(colour, COLOUR_RANGE_COMPOSITE);
}
