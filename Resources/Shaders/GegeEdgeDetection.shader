
Shader "Hidden/Gege/EdgeDetection"
{
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

            TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
            TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);
            TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

            float4 _MainTex_TexelSize;
            float4x4 _ClipToView;

            float4 _OutlineColor;
            float4 _BackgroundColor;
            float _ColorBias;
            float _DepthBias;
            float _OutlineWidth;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float3 viewSpaceDir : TEXCOORD2;
            };

            inline float DecodeFloatRG(float2 enc)
            {
                float2 kDecodeDot = float2(1.0, 1 / 255.0);
                return dot(enc, kDecodeDot);
            }

            inline void DecodeDepthNormal(float4 enc, out float depth, out float3 normal)
            {
                depth = DecodeFloatRG(enc.zw);
                normal = DecodeViewNormalStereo(enc);
            }

            v2f Vert(AttributesDefault v)
            {
                v2f o;
                o.vertex = float4(v.vertex.xy, 0.0, 1.0);
                o.texcoord = TransformTriangleVertexToUV(v.vertex.xy);
                o.viewSpaceDir = mul(_ClipToView, o.vertex).xyz;

            #if UNITY_UV_STARTS_AT_TOP
                o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
            #endif
                return o;
            }

            float4 Frag(v2f i) : SV_Target
            {


                float4 disp = float4(_MainTex_TexelSize.xy, -_MainTex_TexelSize.x, 0) * _OutlineWidth;

                float2 uv0 = i.texcoord;           // TL
                float2 uv1 = i.texcoord + disp.xy; // BR
                float2 uv2 = i.texcoord + disp.xw; // TR
                float2 uv3 = i.texcoord + disp.wy; // BL

                float edge = 0;

                             // sample normal vector values from the main texture
                float3 n0 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, uv0).xyz;
                float3 n1 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, uv1).xyz;
                float3 n2 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, uv2).xyz;
                float3 n3 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, uv3).xyz;

                // roberts cross operator
                float3 ng1 = n1 - n0;
                float3 ng2 = n3 - n2;
                float ng = sqrt(dot(ng1, ng1) + dot(ng2, ng2));

                float4 color = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.texcoord);


                edge = max(edge, ng);

                if (edge > _ColorBias)
                    edge = 1;
                else
                    edge = 0;

                color.rgb = lerp(color.rgb, _BackgroundColor.rgb, _BackgroundColor.a);
                color.rgb = lerp(color.rgb, _OutlineColor.rgb, edge);
                return color;
            }
            ENDHLSL
        }
    }
}

