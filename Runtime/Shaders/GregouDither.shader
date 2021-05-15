Shader "Hidden/Gregou/Dither"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    // Textures Variables
    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_InitTex, sampler_InitTex);
    uniform float4 _MainTex_TexelSize;
    uniform float2 _MainTex_ST;

    // Diffusion Error pivot
    uniform uint _Px = 0;
    uniform uint _Py = 0;

    // User Properties
    uniform float _SumTreeshold;
    uniform float _ColorBlend;
    uniform float4 _DitherColor;
    uniform float _BackgroundColorBlend;
    uniform float4 _BackgroundColor;

    // Local variables
    uniform float2 vertTexCoord;

    float err(int i, int j)
    {
        float4 temp = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,vertTexCoord + float2(i * _MainTex_TexelSize.x, j * _MainTex_TexelSize.y));
        return temp.y * (1.0 - temp.z) - temp.y * temp.z;
    }

    // Pseudo random number generator
    float nrand(float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    // INIT SHADER : Put luminance value into blue channel and random values into red and green
    float4 FragInit(VaryingsDefault i) : SV_Target
    {
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float rnd = nrand(i.texcoord);

        if (rnd > 0.5) {
            rnd = 1.0;
        }
        else {
            rnd = 0.0;
        }
        color.b = (color.r+color.g+color.b)*0.3333;
        color.r = rnd;
        color.g = rnd;
        return color;
    }
    
    // UPDATE SHADER : Propagate noise into the blue channel
    float4 FragPropag(VaryingsDefault i) : SV_Target
    {
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,i.texcoord);

        vertTexCoord = i.texcoord;
       
        float sum = color.b + 
                        0.004310344827586207 * err(-2,-2) + 0.017241379310344827 * err(-1,-2) + 0.03017241379310345 * err(0,-2) + 0.017241379310344827 * err(1,-2) + 0.004310344827586207 * err(2,-2) +
                        0.017241379310344827 * err(-2,-1) + 0.06896551724137931 * err(-1,-1) + 0.11206896551724138 * err(0,-1) + 0.06896551724137931 * err(1,-1) + 0.017241379310344827 * err(2,-1) +
                        0.03017241379310345 * err(-2, 0) + 0.11206896551724138 * err(-1, 0) + 0.0 + 0.11206896551724138 * err(1, 0) + 0.03017241379310345 * err(2, 0) +
                        0.017241379310344827 * err(-2, 1) + 0.06896551724137931 * err(-1, 1) + 0.11206896551724138 * err(0, 1) + 0.06896551724137931 * err(1, 1) + 0.017241379310344827 * err(2, 1) +
                        0.004310344827586207 * err(-2, 2) + 0.017241379310344827 * err(-1, 2) + 0.03017241379310345 * err(0, 2) + 0.017241379310344827 * err(1, 2) + 0.004310344827586207 * err(2, 2);
          
        uint fx = int(i.texcoord.x * _MainTex_TexelSize.z);
        uint fy = int(i.texcoord.y * _MainTex_TexelSize.w);

        float4 newCol = ((sum > _SumTreeshold)) ? float4(color.r, 1 - sum, 1, 1) : float4(color.r, sum, 0, 1);
        return (fx % 3 == _Px) && (fy % 3 == _Py) ? newCol : color;
        //return color;
    }

        
    // FINAL SHADER : Composite final image from previous passes
    float4 FragFinal(VaryingsDefault i) : SV_Target
    {
        float4 originColor = SAMPLE_TEXTURE2D(_InitTex, sampler_InitTex, i.texcoord);
        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

        float4 bg = lerp(originColor, _BackgroundColor, _BackgroundColorBlend);
        float4 fg = lerp(originColor, _DitherColor, _ColorBlend);

        return lerp(fg,bg,col.z);
    }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

            Pass
            {
                HLSLPROGRAM

                    #pragma vertex VertDefault
                    #pragma fragment FragInit

                ENDHLSL
            }
            Pass
            {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment FragPropag

            ENDHLSL
            }
            Pass
            {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment FragFinal

            ENDHLSL
            }
    }
}