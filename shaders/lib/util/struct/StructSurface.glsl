/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_SURFACE

#define SURFACE Surface(vec3(0.0), 0.0, 0.0, 0.0, vec4(0.0), 0.0, 0.0, 0.0, vec3(0.0))

struct Surface {
  vec3 albedo;

  float skyLight;
  float blockLight;
  float material;

  vec4 pbr;

  float roughness;
  float f0; // Under the old PBR format, this represents metalness.
  float emissive;

  vec3 normal;
};

void createSurface(inout Surface surface, in vec4 buffer0, in vec4 buffer1, in vec2 texcoord) {
  // ALBEDO
  surface.albedo = toLinear(decodeColor(buffer0.r));

  // LIGHTMAP
  vec2 lightmap = decodeLightMap(buffer0.g);
  surface.blockLight = lightmap.x;
  surface.skyLight   = lightmap.y;

  // MATERIAL
  surface.material = buffer0.b;

  // NORMAL
  surface.normal = decodeNormal(buffer1.r);

  surface.pbr = vec4(decodeLightMap(buffer1.g), decodeLightMap(buffer1.b));

  surface.roughness = surface.pbr.x;
  surface.f0 = surface.pbr.y;
  surface.emissive = surface.pbr.z;
}

void createSurfaces(inout Surface frontSurface, inout Surface backSurface, inout Fragment fragment, in vec2 texcoord) {
  // FRONT
  createSurface(frontSurface, fragment.tex3, fragment.tex4, texcoord);

  // BACK
  createSurface(backSurface, fragment.tex1, fragment.tex2, texcoord);
}
