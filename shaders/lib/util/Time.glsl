vec2 noonNight   = vec2(0.0);
     noonNight.x = (0.25 - clamp(sunAngle, 0.0, 0.5));
     noonNight.y = (0.75 - clamp(sunAngle, 0.5, 1.0));

// NOON
timeVector.x = 1.0 - clamp01(pow2(abs(noonNight.x) * 4.0));
// NIGHT
timeVector.y = 1.0 - clamp01(pow(abs(noonNight.y) * 4.0, 128.0));
// SUNRISE/SUNSET
timeVector.z = 1.0 - (timeVector.x + timeVector.y);
// MORNING
timeVector.w = 1.0 - ((1.0 - clamp01(pow2(max0(noonNight.x) * 4.0))) + (1.0 - clamp01(pow(max0(noonNight.y) * 4.0, 128.0))));
