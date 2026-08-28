// ============================================================
// Endfield Coordinate HUD
// ============================================================


// Terrain constant buffer.
// Same layout used by the working wall renderer.
cbuffer TerrainCB0 : register(b0)
{
    float4 cb0[82];
};


// Dynamic ASCII output buffer.
RWBuffer<uint> OutputText : register(u0);


// ============================================================
// WRITE ONE CHARACTER
// ============================================================

void WriteChar(inout uint index, uint character)
{
    if (index < 127)
    {
        OutputText[index] = character;
        index++;
    }
}


// ============================================================
// WRITE AN UNSIGNED INTEGER
// ============================================================

void WriteUInt(inout uint index, uint value)
{
    uint digits[10];
    uint count = 0;

    if (value == 0)
    {
        WriteChar(index, 48); // '0'
        return;
    }

    while (value > 0 && count < 10)
    {
        digits[count] = value % 10;
        value /= 10;
        count++;
    }

    while (count > 0)
    {
        count--;

        WriteChar(
            index,
            48 + digits[count]
        );
    }
}


// ============================================================
// WRITE FLOAT WITH 3 DECIMAL PLACES
// ============================================================

void WriteFloat3(inout uint index, float value)
{
    if (value < 0.0)
    {
        WriteChar(index, 45); // '-'
        value = -value;
    }

    uint integerPart =
        (uint)floor(value);

    float fractionalValue =
        value - floor(value);

    uint fractionalPart =
        (uint)round(
            fractionalValue * 1000.0
        );

    // Handle rounding such as:
    //
    // 12.9997 -> 13.000

    if (fractionalPart >= 1000)
    {
        integerPart++;
        fractionalPart = 0;
    }

    WriteUInt(
        index,
        integerPart
    );

    WriteChar(
        index,
        46               // '.'
    );


    // Hundreds digit
    WriteChar(
        index,
        48 + ((fractionalPart / 100) % 10)
    );

    // Tens digit
    WriteChar(
        index,
        48 + ((fractionalPart / 10) % 10)
    );

    // Ones digit
    WriteChar(
        index,
        48 + (fractionalPart % 10)
    );
}


// ============================================================
// WRITE LABEL
// ============================================================

void WriteLabel(
    inout uint index,
    uint letter
)
{
    WriteChar(index, letter);
    WriteChar(index, 58); // ':'
    WriteChar(index, 32); // space
}


// ============================================================
// COMPUTE SHADER
// ============================================================

[numthreads(1, 1, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    // --------------------------------------------------------
    // Clear previous string
    // --------------------------------------------------------

    [unroll]
    for (uint i = 0; i < 128; i++)
    {
        OutputText[i] = 0;
    }


    // --------------------------------------------------------
    // Camera / player position
    // --------------------------------------------------------

    float3 position =
        cb0[44].xyz;


    // --------------------------------------------------------
    // Construct:
    //
    // Position
    // X: 123.456
    // Y: 123.456
    // Z: 123.456
    // --------------------------------------------------------

    uint index = 0;


    // "Position"

    // WriteChar(index, 80);  // P
    // WriteChar(index, 111); // o
    // WriteChar(index, 115); // s
    // WriteChar(index, 105); // i
    // WriteChar(index, 116); // t
    // WriteChar(index, 105); // i
    // WriteChar(index, 111); // o
    // WriteChar(index, 110); // n

    // WriteChar(index, 10);  // newline


    // X

    WriteLabel(
        index,
        88                // X
    );

    WriteFloat3(
        index,
        position.x
    );

   // WriteChar(index, 10);
   WriteChar(index, 32);
WriteChar(index, 32);
WriteChar(index, 32);


    // Y

    WriteLabel(
        index,
        89                // Y
    );

    WriteFloat3(
        index,
        position.y
    );

   // WriteChar(index, 10);
   WriteChar(index, 32);
WriteChar(index, 32);
WriteChar(index, 32);


    // Z

    WriteLabel(
        index,
        90                // Z
    );

    WriteFloat3(
        index,
        position.z
    );


    // Null terminator

    if (index < 128)
    {
        OutputText[index] = 0;
    }
}