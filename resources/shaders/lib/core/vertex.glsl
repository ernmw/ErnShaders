#version 120

#include "lib/core/vertex.h.glsl"

uniform mat4 projectionMatrix;
uniform vec2 screenRes;

#define PS2_JITTER_ENABLED 1
#define PS2_JITTER_GRID_PX 2.0

vec4 applyPolygonJitter(vec4 clipPos)
{
#if PS2_JITTER_ENABLED
    if (clipPos.w > 0.0001)
    {
        float gridX = max(PS2_JITTER_GRID_PX, 1.0) / max(screenRes.x, 1.0);
        float gridY = max(PS2_JITTER_GRID_PX, 1.0) / max(screenRes.y, 1.0);

        // Perspective-divide to NDC space [-1, 1], snap to the pixel
        // grid, then re-multiply by w so the GPU's automatic divide
        // (which happens after this shader runs) reconstructs the
        // snapped position correctly.
        vec2 ndc = clipPos.xy / clipPos.w;
        ndc.x = floor(ndc.x / gridX + 0.5) * gridX;
        ndc.y = floor(ndc.y / gridY + 0.5) * gridY;
        clipPos.xy = ndc * clipPos.w;
    }
#endif
    return clipPos;
}

vec4 modelToClip(vec4 pos)
{
    return viewToClip(modelToView(pos));
}

vec4 modelToView(vec4 pos)
{
    return gl_ModelViewMatrix * pos;
}

vec4 viewToClip(vec4 pos)
{
    return applyPolygonJitter(projectionMatrix * pos);
}
