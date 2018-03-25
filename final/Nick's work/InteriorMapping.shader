Shader "Custom/InteriorMap" {
	Properties {
		_MainTex ("Window placement (testing purposes)", 2D) = "white" {}
		_Wall_1 ("First wall texture", 2D) = "white" {}
		_Wall_2 ("Second wall texture", 2D) = "white" {}
		_Wall_3 ("Third wall texture", 2D) = "white" {}
		_Wall_4 ("Fourth wall texture", 2D) = "white" {}
		_Floor ("Floor texture", 2D) = "white" {}
		_Ceiling ("Ceiling texture", 2D) = "white" {}
		_Exterior ("Building exterior texture", 2D) = "white" {}
		_Window ("Window texture (glass)", 2D) = "white" {}
		[HideInInspector] _BuildingHeight ("Height of the building", Float) = 0.5
		[HideInInspector] _yDist ("y distance between floors", Float) = .125
		[HideInInspector] _xDist ("x distance between walls", Float) = .25
		[HideInInspector] _zDist ("z distance between walls", Float) = .25
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model
		#pragma surface surf Standard vertex:vert

		// Use shader model 3.5 target, to get nicer looking lighting
		#pragma target 3.5

		static float3 right = float3(1, 0, 0);
		static float3 up = float3(0, 1, 0);
		static float3 forward = float3(0, 0, 1);

		struct Input {
			float2 uv_MainTex : TEXCOORD0;
			half3 objectViewDir;
			half3 pos;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			half3 objectCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
			o.objectViewDir = v.vertex.xyz - objectCameraPos;
			o.pos = v.vertex.xyz;
		}

		float intersectDist(float3 rayPos, float3 rayDir, float3 planePos, float3 planeNor) {
			return dot(planePos - rayPos, planeNor) / dot(planeNor, rayDir);
		}

		sampler2D _Wall_1;
		sampler2D _Wall_2;
		sampler2D _Wall_3;
		sampler2D _Wall_4;
		sampler2D _Floor;
		sampler2D _Ceiling;
		sampler2D _Exterior;
		sampler2D _MainTex;
		sampler2D _Window;
		float _BuildingHeight;

		//assumes building is rectangle with scale WxHxD = 1x2x1
		float _yDist;
		float _xDist;
		float _zDist;

		//4 * 8 * 4 * 3
		//float rooms[384];

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//if not looking in a window, just render the outside building texture and return
			if (IN.pos.y >= _BuildingHeight - .001 || IN.pos.y <= -_BuildingHeight + .001 || tex2D(_MainTex, IN.uv_MainTex).r < .5) {
				o.Albedo = tex2D(_Exterior, IN.uv_MainTex).rgb;
				return;
			}
			
			float3 rayDir = normalize(IN.objectViewDir);
			float3 rayPos = IN.pos + rayDir * .0001;

			float closestDist = 1000000000.0;
			float3 intersectPoint;
			float3 plane;
			float3 c = float3(1,1,1);

			//ray dir is angled upward
			if (dot(up, rayDir) > 0) {
				plane = (ceil(rayPos.y / _yDist) * _yDist) * up;
				float intDist = intersectDist(rayPos, rayDir, plane, up);
				if (intDist < closestDist) {
					closestDist = intDist;
					intersectPoint = rayPos + (rayDir * intDist);
					c = tex2D(_Ceiling, float2(intersectPoint.x / _xDist, -intersectPoint.z / _zDist)).rgb; 
				} 
			} else { //ray dir is angled downard
				plane = (ceil((rayPos.y / _yDist) - 1) * _yDist) * up;
				float intDist = intersectDist(rayPos, rayDir, plane, up * -1);
				if (intDist < closestDist) {
					closestDist = intDist;
					intersectPoint = rayPos + (rayDir * intDist);
					c = tex2D(_Floor, float2(intersectPoint.x / _xDist, intersectPoint.z / _zDist)).rgb; 
				}
			}

			//ray dir is angled right
			if (dot(right, rayDir) > 0) {
				plane = (ceil(rayPos.x / _xDist) * _xDist) * right;
				float intDist = intersectDist(rayPos, rayDir, plane, right);
				if (intDist < closestDist) {
					closestDist = intDist;
					intersectPoint = rayPos + (rayDir * intDist);
					c = tex2D(_Wall_3, float2(-intersectPoint.z / _zDist, intersectPoint.y / _yDist)).rgb; 
				} 
			} else { //ray dir is angled left
				plane = (ceil((rayPos.x / _xDist) - 1.0) * _xDist) * right;
				float intDist = intersectDist(rayPos, rayDir, plane, -1 * right);
				if (intDist < closestDist) {
					closestDist = intDist;
					intersectPoint = rayPos + (rayDir * intDist);
					c = tex2D(_Wall_2, float2(intersectPoint.z / _zDist, intersectPoint.y / _yDist)).rgb; 
				}
			}

			//ray dir is angled forward
			if (dot(forward, rayDir) > 0) {
				plane = (ceil(rayPos.z / _zDist) * _zDist) * forward;
				float intDist = intersectDist(rayPos, rayDir, plane, forward);
				if (intDist < closestDist) {
					closestDist = intDist;
					intersectPoint = rayPos + (rayDir * intDist);
					c = tex2D(_Wall_1, float2(intersectPoint.x / _xDist, intersectPoint.y / _yDist)).rgb;
				}
			} else { //ray dir is angled back
				plane = (ceil((rayPos.z / _zDist) - 1.0) * _zDist) * forward;
				float intDist = intersectDist(rayPos, rayDir, plane, -1 * forward);
				if (intDist < closestDist) {
					closestDist = intDist;
					intersectPoint = rayPos + (rayDir * intDist);
					c = tex2D(_Wall_4, float2(-intersectPoint.x / _xDist, intersectPoint.y / _yDist)).rgb;
				}
			}

			float3 glass = tex2D(_Window, IN.uv_MainTex).rgb;
			o.Albedo = lerp(c, glass, 0.6);
			o.Smoothness = .8;
			o.Metallic = .4;

		}
		ENDCG
	}
	FallBack "Diffuse"
}