Shader "Custom/Transparent" {
    Properties {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Alpha ("Alpha", Range(0,1)) = 0.6
    }
	SubShader {
		Tags { "Queue" = "Transparent" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard alpha:fade 
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
		};
        fixed4 _BaseColor;
        half _Alpha;
		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = _BaseColor.rgb;
			o.Alpha = _Alpha;
		}
		ENDCG
	}
	FallBack "Diffuse"
}