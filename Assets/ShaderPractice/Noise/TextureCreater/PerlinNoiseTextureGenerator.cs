using UnityEngine;

// シェーダーの_MaskTexにパーリンノイズを生成してセットする
public class PerlinNoiseTextureGenerator : MonoBehaviour
{
    // Inspectorで設定するパラメータ
    public int textureWidth = 256;
    public int textureHeight = 256;
    public float noiseScale = 20f; // ノイズのスケール（値が小さいほど拡大される）

    void Start()
    {
        // テクスチャを生成してRendererに適用する
        Renderer renderer = GetComponent<Renderer>();
        Texture2D noiseTexture = GeneratePerlinNoiseTexture();
        if (renderer != null)
        {
            renderer.material.SetTexture("_MaskTex", noiseTexture);
        }
    }

    // Perlinノイズテクスチャを生成するメソッド
    Texture2D GeneratePerlinNoiseTexture()
    {
        // 1. Texture2Dオブジェクトを新規作成
        Texture2D perlinTexture = new Texture2D(textureWidth, textureHeight);

        // 2. forループでピクセルを走査
        for (int y = 0; y < textureHeight; y++)
        {
            for (int x = 0; x < textureWidth; x++)
            {
                // 3. Mathf.PerlinNoise()でノイズ値を計算
                //    座標をスケールで割ることで、ノイズの模様を調整する
                float xCoord = (float)x / textureWidth * noiseScale;
                float yCoord = (float)y / textureHeight * noiseScale;

                // PerlinNoiseの戻り値は0.0fから1.0f
                float sample = Mathf.PerlinNoise(xCoord, yCoord);

                // 4. ノイズ値をグレースケールのColorに変換
                Color pixelColor = new Color(sample, sample, sample);

                // 5. ピクセルに色を設定
                perlinTexture.SetPixel(x, y, pixelColor);
            }
        }

        // 6. 変更をテクスチャに適用（非常に重要！）
        perlinTexture.Apply();

        return perlinTexture;
    }
}