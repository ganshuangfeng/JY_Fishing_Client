// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Text 1" 
{
	Properties
	{
		_MainTex ("Alpha (A)", 2D) = "white" {}

		_Color ("Tint", Color) = (1,1,1,1)
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilComp ("Stencil Comparison", Float) = 8
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			//ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _ClipForce = float(1.0);
			float _ClipDepth = float(1.0);
			float2 _ClipDirection = float2(0.0, 0.0);
			float4 _ClipRange = float4(100.0, 100.0, 1.0, 1.0);
			float2 _ClipArgs = float2(1000.0, 1000.0);

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange.zw + _ClipRange.xy;
				return o;
			}

			half4 frag (v2f IN) : SV_Target
			{
				// Softness factor
				//float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs;
				
				float2 factor_ClipArgs = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs;

				float factor_ClipDirection = (IN.worldPos.y * _ClipDirection.y  - float(0.0))
											 + (IN.worldPos.x * _ClipDirection.x - float(0.0));

				float factors = clamp((1 / _ClipDepth), 0.0, 1.0)
						      * clamp((1 - factor_ClipDirection * _ClipForce), 0.0, 1.0) 
							  * clamp( min(factor_ClipArgs.x, factor_ClipArgs.y), 0.0, 1.0);

				// Sample the texture
				half4 col = IN.color;
				col.a *= tex2D(_MainTex, IN.texcoord).a;
				//col.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);
				col.a *= factors;

				return col;
			}
			ENDCG
		}
	}
	Fallback "Unlit/Text"
}
