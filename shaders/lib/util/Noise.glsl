#define INCLUDED_NOISE

float texnoise2D(in sampler2D tex, in vec2 pos) {
  return texture2D(tex, fract(pos)).x;
}

vec4 texnoise3D(in sampler2D tex, in vec3 pos) {
    pos.xy /= noiseTextureResolution;

    vec3 posFloor = floor(pos);
    vec3 posFract = fract(pos);

    return mix(
        texture2D(tex, (posFloor.xy + ( posFloor.z / noiseTextureResolution)) + posFract.xy),
        texture2D(tex, (posFloor.xy + ((posFloor.z + 1.0) / noiseTextureResolution)) + posFract.xy),
        posFract.z
    );
}

float hash13(vec3 p3){
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 hash33(vec3 p3){
    p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+19.19);
    return fract((p3.xxy + p3.yxx)*p3.zyx);
}

float hash12(vec2 p){
    p  = fract(p * .1031);
    p += dot(p, p.yx + 19.19);
    return fract((p.x + p.y) * p.x);
}

vec2 hash22(vec2 p){
    p  = fract(p * vec2(.1031, .1030));
    p += dot(p, p.yx + 19.19);
    return fract((p.xx + p.yx) * p.xy);
}

float simplex3D(vec3 p) {

    vec3 s = floor(p + dot(p, vec3(0.3333333)));
    vec3 x = p - s + dot(s, vec3(0.1666666));

    vec3 e = step(x.yzx, x.xyz);
    e -= e.zxy;

    vec3 i1 = clamp(e   ,0.,1.);
    vec3 i2 = clamp(e+1.,0.,1.);

    vec3 x1 = x - i1 + .1666666;
    vec3 x2 = x - i2 + .3333333;
    vec3 x3 = x - .5;

    vec4 w = vec4(
        dot(x , x ),
        dot(x1, x1),
        dot(x2, x2),
        dot(x3, x3));
    
    w = clamp(.6 - w,0.,1.);
    w *= w;
    w *= w;
    
    vec4 d=vec4(
        dot(hash33(s     )-.5, x ),
        dot(hash33(s + i1)-.5, x1),
        dot(hash33(s + i2)-.5, x2),
        dot(hash33(s + 1.)-.5, x3));

    return dot(d, w*52.);
}

float simplex2D(vec2 p ){
    vec2 s = floor( p + dot(p,vec2(.3660254037844386)));
    vec2 x = p - s + dot(s,vec2(.21132486540518713));
    
    vec2 i1 = step(x.yx,x.xy);    
    vec2 x1 = x - i1 + .21132486540518713;
    vec2 x2 = x - .5773502691896257;
    
    vec3 w = vec3(dot(x,x), dot(x1,x1), dot(x2,x2));

    w = clamp( 0.5-w, 0. ,1.);
    w*=w;
    w*=w;

    vec3 d = vec3(
        dot(hash22(s   )-.5,x ),
        dot(hash22(s+i1)-.5,x1),
        dot(hash22(s+1.)-.5,x2)
    );

    return dot( d, w*140. );
}
