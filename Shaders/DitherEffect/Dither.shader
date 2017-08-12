// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/DitherErrorDiffusion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 screenpos : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.screenpos = ComputeScreenPos(o.vertex);

				return o;
			}
			
			sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;

			uniform float2 _MainTex_ST;
			uniform float2 vertTexCoord;

			uniform int _Px = 0;
			uniform int _Py = 0;

			uniform float _SumTreeshold;

			uniform float _Kernel[25];


			float err(int i, int j) 
			{
      		float4 temp = tex2D(_MainTex, vertTexCoord + float2(i*_MainTex_TexelSize.x, j*_MainTex_TexelSize.y)); 
      		return temp.y*(1.0-temp.z) - temp.y*temp.z; 
      		}

			fixed4 frag (v2f i) : SV_Target{

			    float4 cur = tex2D(_MainTex,i.uv);
			    vertTexCoord = i.uv;

			    float sum = cur.x + _Kernel[ 0]*err(-2,-2) + _Kernel[ 1]*err(-1,-2) + _Kernel[ 2]*err( 0,-2) + _Kernel[ 3]*err( 1,-2) + _Kernel[ 4]*err( 2,-2) + 
                          			_Kernel[ 5]*err(-2,-1) + _Kernel[ 6]*err(-1,-1) + _Kernel[ 7]*err( 0,-1) + _Kernel[ 8]*err( 1,-1) + _Kernel[ 9]*err( 2,-1) + 
                          			_Kernel[10]*err(-2, 0) + _Kernel[11]*err(-1, 0) + _Kernel[12]*err( 0, 0) + _Kernel[13]*err( 1, 0) + _Kernel[14]*err( 2, 0) + 
                          			_Kernel[15]*err(-2, 1) + _Kernel[16]*err(-1, 1) + _Kernel[17]*err( 0, 1) + _Kernel[18]*err( 1, 1) + _Kernel[19]*err( 2, 1) + 
                          			_Kernel[20]*err(-2, 2) + _Kernel[21]*err(-1, 2) + _Kernel[22]*err( 0, 2) + _Kernel[23]*err( 1, 2) + _Kernel[24]*err( 2, 2);

                int fx = int(i.uv.x*_MainTex_TexelSize.z);
                int fy = int(i.uv.y*_MainTex_TexelSize.w);

				float4 newCol = ((sum > _SumTreeshold))?float4(cur.x,1-sum,1,1):float4(cur.x,sum,0,1);
      			float4 col = (fx%3 == _Px) && (fy%3 == _Py)	?	newCol:cur;
      			return col;
			}
			ENDCG
		}
	}
}
