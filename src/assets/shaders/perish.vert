#pragma language glsl3
extern number time;
extern number duration;
extern vec2 velocity;
extern vec2 impactPoint;

vec2 scale = love_ScreenSize.xy;
float t = sqrt(time / duration);
ivec2 scatterSample(vec2 tc)
{
    vec2 dir = tc - (impactPoint / scale);
    vec2 dirNorm = normalize(dir);
    vec2 velocityNorm = normalize(velocity);
    if (dot(dirNorm, velocityNorm) < 0) {
        return ivec2(0, 0);
    }
    float scatterRange = 1.0 + pow(length(dir), 2);
    float scatterStrength = length(velocity) * t / 2000.0;
    vec2 displacement = dirNorm * scatterStrength * scatterRange;
    return ivec2(displacement * scale);
}

vec4 effect(vec4 c, Image tx, vec2 tc, vec2 sc)
{
    float seed = fract(sin(dot(tc, vec2(12.9898, 78.233))) * 43758.5453);
    vec4 pixel;
    ivec2 target = scatterSample(tc);
    if (target == scatterSample(tc + vec2(1, 0) / scale) && target == scatterSample(tc + vec2(0, 1) / scale))
    {
        pixel = Texel(tx, tc - target / scale);
    } else
    {
        pixel = vec4(0, 0, 0, 0);
    }
    pixel.a *= (1.0 - max(time / duration + seed / 2, 0));

    return pixel * c;
}
