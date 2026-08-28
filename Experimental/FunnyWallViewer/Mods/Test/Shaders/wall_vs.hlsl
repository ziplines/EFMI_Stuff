
struct VSOut
{
    float4 pos : SV_Position;
    float2 uv  : TEXCOORD0;
};

VSOut main(
    float3 inPos : POSITION,
    float2 inUV  : TEXCOORD0
)
{
    VSOut o;

    /*
        TEST PROJECTION ONLY.

        X becomes screen X.
        Z becomes screen Y.

        The actual game camera will be added later.
    */

    o.pos = float4(
        inPos.x * 0.01,
        inPos.z * 0.01,
        0.5,
        1.0
    );

    o.uv = inUV;

    return o;
}
