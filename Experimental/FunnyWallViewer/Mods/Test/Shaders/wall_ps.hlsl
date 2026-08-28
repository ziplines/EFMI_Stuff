
float4 main(
    float4 pos : SV_Position,
    float2 uv : TEXCOORD0
) : SV_Target
{
    return float4(
        1.0,
        0.0,
        0.0,
        1.0
    );
}
