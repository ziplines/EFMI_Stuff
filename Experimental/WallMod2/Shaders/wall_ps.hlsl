float4 main(
    float4 pos : SV_Position,
    float2 uv  : TEXCOORD0,
    nointerpolation float dist : TEXCOORD1   // CHANGED — matches VS
) : SV_Target
{
    const float MAX_DIST = 200.0;
    if (dist > MAX_DIST)
        discard;

    // ========================================================
    // TRIANGLE BARYCENTRIC COORDINATES
    //
    // Exported triangle UVs:
    //
    //   vertex 0 -> (0, 0)
    //   vertex 1 -> (1, 0)
    //   vertex 2 -> (0, 1)
    //
    // This lets us detect proximity to each triangle edge.
    // ========================================================

    float3 bary = float3(
        uv.x,
        uv.y,
        1.0 - uv.x - uv.y
    );


    // ========================================================
    // SCREEN-SPACE EDGE WIDTH
    //
    // fwidth() keeps borders reasonably consistent in pixel
    // width as distance from the camera changes.
    // ========================================================

    float3 derivative =
        fwidth(bary);


    // Increase OUTER_WIDTH for thicker borders.
    const float INNER_WIDTH = 1.5;
    const float OUTER_WIDTH = 2.0;


    float3 interiorMask =
        smoothstep(
            derivative * INNER_WIDTH,
            derivative * OUTER_WIDTH,
            bary
        );


    float interior =
        min(
            interiorMask.x,
            min(
                interiorMask.y,
                interiorMask.z
            )
        );


    // 1 = edge
    // 0 = interior
    float edge =
        1.0 - interior;


    // ========================================================
    // COLORS
    // ========================================================

    float4 faceColor = float4(
        0.0,    // R
        1.0,    // G
        1.0,    // B
        0.1    // Alpha
    );


    float4 edgeColor = float4(
        0.0,    // R
        0.1,   // G
        0.3,    // B
        0.5    // Alpha
    );


    return lerp(
        faceColor,
        edgeColor,
        edge
    );
}