// DIRECT LIGHT
lightColours[0]  = js_getScatter(vec3(0.0), lightVector, 0);
lightColours[0] *= DIRECT_BRIGHTNESS_NOON * timeVector.x + DIRECT_BRIGHTNESS_NIGHT * timeVector.y + DIRECT_BRIGHTNESS_HORIZON * timeVector.z;
lightColours[0] *= mix(1.0, DIRECT_BRIGHTNESS_RAIN, wetness);

// AMBIENT LIGHT
lightColours[1]  = js_getScatter(vec3(0.0), upVector, 0);
lightColours[1] *= AMBIENT_BRIGHTNESS;
