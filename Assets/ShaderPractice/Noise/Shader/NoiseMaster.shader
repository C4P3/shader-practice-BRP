// シェーダー名: NoiseMaster.shader
// 保存場所: Project内の任意の場所 (例: Assets/Shaders/)
Shader "Custom/NoiseMaster"
{
    Properties
    {
        // ノイズの種類を選択するドロップダウン
        [Enum(Random, 0, Block, 1, Value, 2, Perlin, 3, FBM, 4)] _NoiseType ("Noise Type", Float) = 0

        // 共通および個別のパラメータ
        _Scale ("Scale", Range(1, 200)) = 50
        _GridSize ("Grid Size (for Block)", Range(2, 50)) = 10

        // FBM用のパラメータ
        [IntRange] _Octaves ("Octaves (for FBM)", Range(1, 10)) = 5
        _Lacunarity ("Lacunarity (for FBM)", Range(1.1, 4.0)) = 2.0
        _Gain ("Gain (for FBM)", Range(0.1, 1.0)) = 0.5
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

            // 頂点シェーダーの入力構造体
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // 頂点シェーダーからフラグメントシェーダーへの出力構造体
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // 各プロパティに対応する変数を宣言
            float _NoiseType;
            float _Scale;
            float _GridSize;
            int _Octaves;
            float _Lacunarity;
            float _Gain;

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // --- ここからノイズ関数の実装 ---

            // 1. ランダムノイズ (ホワイトノイズ)
            // 入力された座標に基づいて疑似乱数を返す
            float random (fixed2 p)
            {
                return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
            }

            // 2. ブロックノイズ (セルノイズ)
            // 座標を整数に丸めてグリッド化し、セルごとにランダムな値を返す
            float blockNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                return random(p);
            }

            // 3. バリューノイズ
            // グリッドの各頂点のランダム値をスムーズに補間する
            float valueNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);

                float v00 = random(p + fixed2(0, 0));
                float v10 = random(p + fixed2(1, 0));
                float v01 = random(p + fixed2(0, 1));
                float v11 = random(p + fixed2(1, 1));
                
                // スムーズな補間のための Smoothstep (f*f*(3-2f))
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v0010 = lerp(v00, v10, u.x);
                float v0111 = lerp(v01, v11, u.x);
                return lerp(v0010, v0111, u.y);
            }
            
            // Perlinノイズ用の2Dランダム（勾配ベクトル生成用）
            fixed2 random2(fixed2 st)
            {
                st = fixed2(dot(st, fixed2(127.1, 311.7)),
                            dot(st, fixed2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            // 4. パーリンノイズ
            // グリッドの各頂点のランダムな「勾配」を元に補間する
            float perlinNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f * f * (3.0 - 2.0 * f);

                // 各頂点の勾配ベクトルを取得
                float g00 = dot(random2(p + fixed2(0, 0)), f - fixed2(0, 0));
                float g10 = dot(random2(p + fixed2(1, 0)), f - fixed2(1, 0));
                float g01 = dot(random2(p + fixed2(0, 1)), f - fixed2(0, 1));
                float g11 = dot(random2(p + fixed2(1, 1)), f - fixed2(1, 1));

                // 補間して結果を [0, 1] の範囲に補正
                return lerp(lerp(g00, g10, u.x),
                            lerp(g01, g11, u.x),
                            u.y) + 0.5;
            }

            // 5. fBm (fractal Brownian Motion)
            // パーリンノイズを異なる周波数・振幅で重ね合わせる
            float fbm(fixed2 st, int octaves, float lacunarity, float gain)
            {
                float total = 0.0;
                float frequency = 1.0;
                float amplitude = 1.0;
                float maxValue = 0.0; // 正規化用

                for (int i = 0; i < octaves; i++)
                {
                    total += amplitude * perlinNoise(st * frequency);
                    maxValue += amplitude;
                    amplitude *= gain;
                    frequency *= lacunarity;
                }
                
                // 結果が常に [0, 1] の範囲に収まるように正規化
                return total / maxValue;
            }


            // === フラグメントシェーダー ===
            fixed4 frag (v2f i) : SV_Target
            {
                // _NoiseTypeの値に応じて処理を分岐
                float noise = 0;

                if (_NoiseType == 0) // Random
                {
                    // ピクセルごとに完全にランダムな値にする
                    // UV座標に大きな値を乗算して、隣接ピクセルでも値が大きく変わるようにする
                    noise = random(i.uv * 1000.0);
                }
                else if (_NoiseType == 1) // Block
                {
                    // _GridSizeで指定された分割数でブロック状のノイズを生成
                    noise = blockNoise(i.uv * _GridSize);
                }
                else if (_NoiseType == 2) // Value
                {
                    noise = valueNoise(i.uv * _Scale);
                }
                else if (_NoiseType == 3) // Perlin
                {
                    noise = perlinNoise(i.uv * _Scale);
                }
                else if (_NoiseType == 4) // FBM
                {
                    noise = fbm(i.uv * _Scale, _Octaves, _Lacunarity, _Gain);
                }

                return fixed4(noise, noise, noise, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    // このシェーダーに対応するカスタムエディタを指定
    CustomEditor "NoiseMasterGUI"
}