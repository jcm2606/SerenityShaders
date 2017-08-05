/*
  SERENITY SHADER PACK.
  JCM2606 / JAKEMICHIE97.
  SHADERLABS.

  Please read "License.txt" at the root of the shader pack before making any edits.
*/

sunVector = fnormalize(sunPosition);
moonVector = fnormalize(-sunPosition);

lightVector = (sunAngle > 0.5) ? moonVector : sunVector;
