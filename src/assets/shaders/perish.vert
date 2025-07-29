#pragma language glsl3
//extern number time;
vec4 effect(vec4 c, Image tx, vec2 tc, vec2 sc)
{
    vec4 pixel = Texel(tx, vec2(tc.x, tc.y));
    return pixel * c;
}
