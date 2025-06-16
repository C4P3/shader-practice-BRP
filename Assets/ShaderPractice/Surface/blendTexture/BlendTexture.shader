Shader "Custom/BlendTexture"
{
    Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SubTex ("Sub Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        // ブレンドの偏りを制御するパラメータを追加
        _BlendFactor ("Blend Factor", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SubTex;
        sampler2D _MaskTex;
        // Propertiesで定義した変数をCg側で受け取る
        fixed _BlendFactor;

        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c1 = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 c2 = tex2D (_SubTex,  IN.uv_MainTex);
            // マスクテクスチャのRチャンネルを使用 (グレースケールを想定)
            fixed mask = tex2D (_MaskTex, IN.uv_MainTex).r;
            
            fixed t; // 最終的なlerpの補間係数

            // _BlendFactorの値に応じて補間係数tを計算
            if (_BlendFactor < 0.5)
            {
                // [0.0 -> 0.5]の範囲を[0.0 -> 1.0]の範囲にリマップし、
                // 0からマスク値へ補間する
                t = lerp(0.0, mask, _BlendFactor * 2.0);
            }
            else
            {
                // [0.5 -> 1.0]の範囲を[0.0 -> 1.0]の範囲にリマップし、
                // マスク値から1へ補間する
                t = lerp(mask, 1.0, (_BlendFactor - 0.5) * 2.0);
            }
            
            // 計算された係数tを使って最終的な色を決定
            o.Albedo = lerp(c1, c2, t);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
