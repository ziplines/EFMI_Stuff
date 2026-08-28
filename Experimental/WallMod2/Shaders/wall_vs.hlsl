// Shaders/wall_vs.hlsl

cbuffer TerrainCB0 : register(b0)
{
    float4 cb0[82];
};

cbuffer TerrainCB1 : register(b1)
{
    float4 cb1[20];
};

struct VSOut
{
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
    nointerpolation float dist : TEXCOORD1;   // CHANGED — flat, not interpolated
};

VSOut main(
    float3 inPos : POSITION,
    float2 inUV : TEXCOORD0
)
{
    VSOut o;

    float3 gamePos = float3(
         inPos.x,
         inPos.z,
        -inPos.y
    );

    float3 relativePos =
        gamePos - cb0[44].xyz;

    o.dist = length(relativePos);

    float4 clip =
          cb0[32] * relativePos.x
        + cb0[33] * relativePos.y
        + cb0[34] * relativePos.z
        + cb0[35];

    float2 jitter =
        cb1[19].zw * clip.w;

    clip.xy +=
        -jitter * float2(2.0, -2.0);

    clip.y = -clip.y;

    o.pos = clip;
    o.uv = inUV;

    return o;
}