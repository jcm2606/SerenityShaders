/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

#define INCLUDED_FRAGMENT

struct Fragment {
  vec4 tex0;
  vec4 tex1;
  vec4 tex2;
  vec4 tex3;
  vec4 tex4;
  vec4 tex5;
  vec4 tex6;
  vec4 tex7;
};

void createFragment(inout Fragment fragment, in vec2 texcoord) {
  #ifdef IN_TEX0
    fragment.tex0 = texture2DLod(colortex0, texcoord, 0);
  #endif

  #ifdef IN_TEX1
    fragment.tex1 = texture2DLod(colortex1, texcoord, 0);
  #endif

  #ifdef IN_TEX2
    fragment.tex2 = texture2DLod(colortex2, texcoord, 0);
  #endif

  #ifdef IN_TEX3
    fragment.tex3 = texture2DLod(colortex3, texcoord, 0);
  #endif

  #ifdef IN_TEX4
    fragment.tex4 = texture2DLod(colortex4, texcoord, 0);
  #endif

  #ifdef IN_TEX5
    fragment.tex5 = texture2DLod(colortex5, texcoord, 0);
  #endif

  #ifdef IN_TEX6
    fragment.tex6 = texture2DLod(colortex6, texcoord, 0);
  #endif

  #ifdef IN_TEX7
    fragment.tex7 = texture2DLod(colortex7, texcoord, 0);
  #endif
}
