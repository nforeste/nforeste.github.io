Shader "Custom/Teleport" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.0
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_DissolveScale ("DissolveScale", Range(0,1)) = 0.43
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_DissolveStart("Teleportation Start", Vector) = (0, 3, 0, 1)
		_DissolveEnd("Teleportation End", Vector) = (0, -4.4, 0, 1)
		_Cross("Cross Size", Float) = 0.6
		_TeleIntensity("Teleportation Intensity", Range(0.0, 5.0)) = 2.46
		_TeleScale("Teleportation Size", Range(0.0, 5.0)) = 1.35
		_Tele("Teleportation Color", Color) = (1, 1, 1, 1)
		_TeleEnd("Teleportation End Color", Color) = (1, 1, 1, 1)
		_TeleColFac("Teleportation Colorshift", Range(0.01, 2.0)) = 0.84

	}
	SubShader {
		Tags { 
		"Queue" = "Transparent"
		"RenderType" = "Fade"
		}
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NoiseTex;

		struct Input {
			float2 uv_MainTex;
			float2 dGeometry;
		};

		half _Glossiness;
		half _Metallic;
		half _Alpha1;
		fixed4 _Color;
		half _DissolveScale;
		half _Cross;
		half4 _DissolveEnd;
		half4 _DissolveStart;
		half _TeleIntensity;
		half _TeleScale;
		fixed4 _Tele;
		fixed4 _TeleEnd;
		half _TeleColFac;


		static float3 dir = normalize(_DissolveEnd - _DissolveStart);
		static float3 newDissolveStart = _DissolveStart - _Cross * dir;
		static float dCross = 1.0f / _Cross;

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input,o);
			float3 pt = lerp(newDissolveStart, _DissolveEnd, _DissolveScale);
			o.dGeometry = dot(v.vertex - pt, dir) * dCross;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half base = -2.0f * (_DissolveScale +  _SinTime[2]) + 1.0f;


			fixed4 tex = tex2D(_NoiseTex, IN.uv_MainTex);
			half noise = tex.r + base;
			half dFinal = noise + IN.dGeometry;
			half alpha = clamp(dFinal, 0.0f, 1.0f);

			half dPredict = (_TeleScale - dFinal) * _TeleIntensity;
			half dPredictCol = (_TeleScale * _TeleColFac - dFinal) * _TeleIntensity;
			fixed4 TeleLine = dPredict * lerp(_Tele, _TeleEnd, clamp(dPredictCol, 0.0f, 1.0f));
			TeleLine = clamp(TeleLine, 0.0f, 1.0f);


			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Emission = TeleLine;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = alpha;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
