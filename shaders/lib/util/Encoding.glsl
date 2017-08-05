/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#ifndef INCLUDED_DITHER
    #include "/lib/util/Dither.glsl"
#endif

const vec3 values = exp2( vec3( 5, 6, 5 ) );
const vec3 maxValues = values - 1.;
const vec3 rmaxValues = 1. / maxValues;
const vec3 positions = vec3( 1., values.x, values.x*values.y );
const vec3 rpositions = 65535. / positions;

float encodeColor(vec3 a){
    a += (bayer8(gl_FragCoord.xy)-.5) / maxValues;
    a = clamp(a, 0., 1.);
    return dot( round( a * maxValues ), positions ) / 65535.;
}

vec3 decodeColor(float a){
    return mod( a * rpositions, values ) * rmaxValues;
}

float encodeLightMap(vec2 a){
    ivec2 bf = ivec2(a*255.);
    return float( bf.x|(bf.y<<8) ) / 65535.;
}

vec2 decodeLightMap(float a){
    int bf = int(a*65535.);
    return vec2(bf%256, bf>>8) / 255.;
}

const float bits = 11.0;

const float exp2Bits0 = exp2(bits + 2.0);
const float inverseExp2Bits0 = 1.0 / exp2Bits0;

const vec2 inverseExp2Bits1 = vec2(1.0) / exp2(vec2(bits, bits * 2.0 + 2.0));

float encodeNormal(in vec3 normal) {
	normal = clamp(normal, -1.0, 1.0);

	normal.xy = round(((vec2(atan(normal.x, normal.z), acos(normal.y)) / pi) + vec2(1.0, 0.0)) * exp2(bits));
	
	return normal.x + normal.y * exp2Bits0;
}

vec3 decodeNormal(in float encodedNormal) {
    vec4 normal = vec4(0.0);

    normal.y = exp2Bits0 * floor(encodedNormal * inverseExp2Bits0);
    normal.x = encodedNormal - normal.y;

    normal.xy = ((normal.xy * inverseExp2Bits1) - vec2(1.0, 0.0)) * pi;
    normal.xwzy = vec4(sin(normal.xy), cos(normal.xy));
    
    normal.xz *= normal.w;
    
    return normal.xyz;
}
