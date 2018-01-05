Shader "Hidden/GoldenTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DistColor("Distortion Color Texture", 2D) = "white" {}
		_DistTex("Distortion Texture", 2D) = "black" {}
		_DistMask("Distortion Mask", 2D) = "white" {}

		_BlazeTex("Blaze Texture", 2D) = "black" {}
		_BlazeMotion("Blaze Motion Texture", 2D) = "black" {}
		_BlazeColor ("Blaze Color Tint", Color) = (1, 1, 1, 1)
		_BlazeSpeed ("Blaze Motion Speed", float) = 5.0
		_BlazePivotScale ("Blaze Pivot Point and Scale", Vector) = (0.5, 0.5, 1, 1)

		_HaloTex("Halo Texture", 2D) = "black" {}
		_HaloColor("Halo Color Tint", Color) = (1, 1, 1, 1)
		_HaloRotation("Halo Rotation Speed", float) = 10
		_HaloPivotScale("Halo Pivot Point and Scale", Vector) = (0.5, 0.5, 1, 1)
		_HaloTranslation("Halo Translation", Vector) = (0, 0, 0, 0)
	}
		SubShader
	{
		// No culling or depth
		Tags {"Queue" = "Transparent" "RenderType" = "Transparent" "PreviewType" = "Plane"}
		ZWrite Off
		Blend One One
		Cull Off
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _DistTex;
			sampler2D _DistColor;
			sampler2D _DistMask;

			sampler2D _BlazeTex;
			sampler2D _BlazeMotion;
			fixed4 _BlazeColor;
			float _BlazeSpeed;
			float4 _BlazePivotScale;

			sampler2D _HaloTex;
			fixed4 _HaloColor;
			float _HaloRotation;
			float4 _HaloPivotScale;
			float4 _HaloTranslation;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uvBlaze : TEXCOORD1;
				float2 uvHalo : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uvBlaze = (v.uv - _BlazePivotScale.xy) * (1 / _BlazePivotScale.zw);

				float2x2 rotationMatrix;
				float sinTheta;
				float cosTheta;

				o.uvHalo = (v.uv - _HaloPivotScale.xy);
				sinTheta = sin(_HaloRotation * _Time);
				cosTheta = cos(_HaloRotation * _Time);
				rotationMatrix = float2x2(cosTheta, -sinTheta, sinTheta, cosTheta);
				o.uvHalo = mul(rotationMatrix, (o.uvHalo - _HaloTranslation.xy)*(1 / _HaloPivotScale.zw)) + _HaloPivotScale.xy;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 timeScroll = float2(_Time.x, _Time.x);
				fixed2 dist = (tex2D(_DistTex, i.uv + timeScroll).rg - 0.5) * 2;
				fixed4 distColor = tex2D(_DistColor, i.uv + dist * 0.025 + float2(0, 0.1));
				fixed4 distMask = tex2D(_DistMask, i.uv);
				if (distColor.r == 0)
					distColor.a = 0;

				fixed4 color = tex2D(_MainTex, i.uv) + distColor * distMask.r;
				
				fixed4 blazeMotion = tex2D(_BlazeMotion, i.uv);
				if (_BlazeSpeed > 0)
					blazeMotion.y -= _Time.x * _BlazeSpeed;

				fixed4 blaze = tex2D(_BlazeTex, blazeMotion.xy) * blazeMotion.a;
				blaze *= _BlazeColor;

				color += blaze * blaze.a;
				
				fixed4 halo = tex2D(_HaloTex, i.uvHalo);
				halo.rbg *= _HaloColor.rgb;
				color += halo * halo.a;
				
				return color;
			}
			ENDCG
		}
	}
}
