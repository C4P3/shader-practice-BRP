Shader "Custom/Rim" {
    Properties {
        _BaseColor ("Base Color", Color) = (0.05, 0.1, 0, 1)
        _RimColor ("Rim Color", Color) = (0.5,0.7,0.5,1)
		_Strength ("Strength", Range(1,3)) = 2.5
    }
	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
			float3 viewDir;
		};
		fixed4 _BaseColor;
		fixed4 _RimColor;
		half _Strength;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = _BaseColor.rgb;
			float rim = 1 - saturate(dot(IN.viewDir, o.Normal));
			o.Emission =  _RimColor * pow(rim, _Strength);
		}
		ENDCG
	}
	FallBack "Diffuse"
}