#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uSquishAngleOrigin;
uniform float uSquishFactor;

uniform sampler2D tTexture;

out vec4 fragColor;

void fragment(vec2 uv, vec2 pos, inout vec4 color) {

    vec2 transformedUV = uv.xy;

    transformedUV -= 0.5;

    float angle = radians(uSquishAngleOrigin);

    float cosAngle = cos(angle);
    float sinAngle = sin(angle);
    mat2 rotationMatrix = mat2(cosAngle, -sinAngle, sinAngle, cosAngle);

    transformedUV = rotationMatrix * transformedUV;

    float squishFactor = uSquishFactor;
    float halfSquishFactor = ((squishFactor - 1.0) * 0.5) + 1.0; 

    transformedUV.y = (transformedUV.y * squishFactor) + (1.0 - squishFactor) * 0.0;
    transformedUV.x = (transformedUV.x * (1.0 / halfSquishFactor)) + (1.0 - (1.0 / halfSquishFactor)) * 0.0;

    mat2 inverseRotationMatrix = mat2(cosAngle, sinAngle, -sinAngle, cosAngle);
    transformedUV = inverseRotationMatrix * transformedUV;

    transformedUV += 0.5;

    if(transformedUV.x < 0.0 || transformedUV.x > 1.0 || transformedUV.y < 0.0 || transformedUV.y > 1.0) {
        color = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    color = texture(tTexture, transformedUV);
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    vec4 color;

    fragment(uv, pos, color);

    fragColor = color;
}
