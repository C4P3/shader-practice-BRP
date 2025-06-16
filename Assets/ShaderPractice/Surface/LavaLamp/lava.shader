Shader "Custom/SeamlessLava"
{
    // インスペクターで編集可能な項目
    Properties
    {
        _LavaColor ("Lava Color", Color) = (1, 0.5, 0.2, 1)
        _Tiling ("Tiling", Float) = 2.0
        _FlowSpeed ("Flow Speed", Float) = 0.5
        _NoiseIntensity ("Noise Intensity", Range(0, 100)) = 40.0
        _Brightness ("Brightness", Range(-1, 1)) = -0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Propertiesで定義した変数をシェーダー内で使えるように宣言
            fixed4 _LavaColor;
            half _Tiling;
            half _FlowSpeed;
            half _NoiseIntensity;
            half _Brightness;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                // オブジェクトのローカル座標を受け渡すために追加
                float3 objPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // 頂点のローカル座標をフラグメントシェーダーへ渡す
                o.objPos = v.vertex.xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // UVの代わりにオブジェクト座標のxz平面を使用する
                half2 p = i.objPos.xz * _Tiling;
                // Y座標と時間でアニメーションさせる
                p.y += i.objPos.y * _Tiling - _Time.y * _FlowSpeed;

                half2 a = p;
                half2 f = frac(a); a -= f; f = f*f*(3.-2.*f);
                half4 r = frac(sin((a.x + a.y*1e3) + half4(0, 1, 1e3, 1001)) * 1e5) * _NoiseIntensity / (i.uv.y * 20 + 1);

                half noise = lerp(lerp(r.x, r.y, f.x), lerp(r.z, r.w, f.x), f.y);
                
                // 色の計算
                fixed3 color = _LavaColor.rgb * clamp(noise + _Brightness, 0.0, 1.0);
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}