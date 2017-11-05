Shader "Custom/04" 
{
	Properties
	{
		_NormalTex("Normal Map", 2D) = "white"
	}
	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			sampler2D _NormalTex;
			float4 _NormalTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.uv = TRANSFORM_TEX(v.uv, _NormalTex);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 tangentNormal = tex2D(_NormalTex, i.uv) * 2 - 1;
				return dot(tangentNormal, _WorldSpaceLightPos0);
			}
			ENDCG
		}
	}
}
