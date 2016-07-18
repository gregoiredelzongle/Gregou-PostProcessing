Shader "Hidden/GreWernessDitherShader"
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
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
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

			float err(int i, int j) 
			{
      		float4 temp = tex2D(_MainTex, vertTexCoord + float2(i*_MainTex_TexelSize.x, j*_MainTex_TexelSize.y)); 
      		return temp.y*(1.0-temp.z) - temp.y*temp.z; 
      		}

			fixed4 frag (v2f i) : SV_Target
			{

				// Init the kernel
				#define B 232.0
	
				float kernel[25];         
			    kernel[0] = 1.0/B;    
			    kernel[1] = 4.0/B;     
			    kernel[2] = 7.0/B;    
			    kernel[3] = 4.0/B;     
			    kernel[4] = 1.0/B; 
			    kernel[5] = 4.0/B;  
			    kernel[6] = 16.0/B;  
			    kernel[7] = 26.0/B; 
			    kernel[8] = 16.0/B;  
			    kernel[9] = 4.0/B; 
			    kernel[10] = 7.0/B;  
			    kernel[11] = 26.0/B;  
			    kernel[12] = 0.0/B;  
			    kernel[13] = 26.0/B;  
			    kernel[14] = 7.0/B; 
			    kernel[15] = 4.0/B;  
			    kernel[16] = 16.0/B;  
			    kernel[17] = 26.0/B; 
			    kernel[18] = 16.0/B;  
			    kernel[19] = 4.0/B; 
			    kernel[20] = 1.0/B;  
			    kernel[21] = 4.0/B;   
			    kernel[22] = 7.0/B;  
			    kernel[23] = 4.0/B;   
			    kernel[24] = 1.0/B;

			    // Get current pixel color
			    float4 cur = tex2D(_MainTex,i.uv);
			    vertTexCoord = i.uv;

			    float sum = cur.x + kernel[ 0]*err(-2,-2) + kernel[ 1]*err(-1,-2) + kernel[ 2]*err( 0,-2) + kernel[ 3]*err( 1,-2) + kernel[ 4]*err( 2,-2) + 
                          			kernel[ 5]*err(-2,-1) + kernel[ 6]*err(-1,-1) + kernel[ 7]*err( 0,-1) + kernel[ 8]*err( 1,-1) + kernel[ 9]*err( 2,-1) + 
                          			kernel[10]*err(-2, 0) + kernel[11]*err(-1, 0) + kernel[12]*err( 0, 0) + kernel[13]*err( 1, 0) + kernel[14]*err( 2, 0) + 
                          			kernel[15]*err(-2, 1) + kernel[16]*err(-1, 1) + kernel[17]*err( 0, 1) + kernel[18]*err( 1, 1) + kernel[19]*err( 2, 1) + 
                          			kernel[20]*err(-2, 2) + kernel[21]*err(-1, 2) + kernel[22]*err( 0, 2) + kernel[23]*err( 1, 2) + kernel[24]*err( 2, 2);

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
