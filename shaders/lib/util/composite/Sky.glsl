#define INCLUDED_SKY

#ifndef INCLUDED_ATMOSPHERE
  #include "/lib/util/composite/Atmosphere.glsl"
#endif

#ifndef INCLUDED_STARS
  #include "/lib/util/composite/Stars.glsl"
#endif

vec3 drawSky(in vec3 view, in int mode) {
  return js_getScatter(drawStars(view), view, sunVector, mode);
}
