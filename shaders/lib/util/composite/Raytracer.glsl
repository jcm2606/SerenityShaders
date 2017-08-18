/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_RAYTRACER

#ifndef INCLUDED_DITHER
  #include "/lib/util/Dither.glsl"
#endif

vec4 raytrace(vec3 dir,vec3 position){
    const float quality = 15.;
    const float qualityinv = 1.0 / quality;
    vec3 clipPosition = getScreenSpacePosition(position);
    vec3 direction = normalize(getScreenSpacePosition(position+dir)-clipPosition);  //convert to clip space
    direction.xy = normalize(direction.xy);
    //get at which length the ray intersects with the edge of the screen
    vec3 maxLengths = (step(0.,direction)-clipPosition) / direction;
    float mult = min(min(maxLengths.x,maxLengths.y),maxLengths.z);
    vec3 stepv = direction * mult * qualityinv;
    vec3 spos = clipPosition;

    float dither = bayer16(texcoord);

    for (int i = 0; i < int(quality); i++) {
        spos = stepv * min( float(i+1) + dither - .5, quality ) + clipPosition;
        if( texture2D(depthtex0,spos.xy).x < spos.z )
            break;
    }

    //refinements
    spos -= stepv * .5;
    spos -= stepv * .25     * sign( spos.z - texture2D(depthtex0,spos.xy).x );
    spos -= stepv * .125    * sign( spos.z - texture2D(depthtex0,spos.xy).x );
    spos -= stepv * .0625   * sign( spos.z - texture2D(depthtex0,spos.xy).x );
    spos -= stepv * .03125  * sign( spos.z - texture2D(depthtex0,spos.xy).x );
    float rejectSample = texture2D(depthtex0,spos.xy).x;
    spos -= stepv * .015625 * sign( spos.z - rejectSample );
    if( 
        abs(spos.z-rejectSample) < .001 * qualityinv + abs(stepv.z) //not backface
        &&rejectSample < 1.//not sky
    )
        return vec4(texture2D(colortex0,spos.xy).rgb, 1.0);
    return vec4(0.0);
}
