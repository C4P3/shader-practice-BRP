// スクリプト名: NoiseMasterGUI.cs
// 保存場所: Project内の "Editor" フォルダ
using UnityEngine;
using UnityEditor;

public class NoiseMasterGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // プロパティを取得
        MaterialProperty noiseType = FindProperty("_NoiseType", properties);
        MaterialProperty scale = FindProperty("_Scale", properties);
        MaterialProperty gridSize = FindProperty("_GridSize", properties);
        MaterialProperty octaves = FindProperty("_Octaves", properties);
        MaterialProperty lacunarity = FindProperty("_Lacunarity", properties);
        MaterialProperty gain = FindProperty("_Gain", properties);

        // GUIの描画開始
        materialEditor.ShaderProperty(noiseType, "Noise Type");

        // noiseTypeの値（Enumのインデックス）を取得
        int noiseIndex = (int)noiseType.floatValue;

        // ノイズの種類によって表示するプロパティを切り替え
        // 0:Random, 1:Block, 2:Value, 3:Perlin, 4:FBM
        
        // ランダムノイズの場合はスケール不要なので表示しない
        if (noiseIndex != 0)
        {
            if (noiseIndex == 1) // Block Noise
            {
                materialEditor.ShaderProperty(gridSize, "Grid Size");
            }
            else // Value, Perlin, FBM
            {
                materialEditor.ShaderProperty(scale, "Scale");
            }
        }
        
        // FBMが選択されている時だけFBM用のパラメータを表示
        if (noiseIndex == 4)
        {
            // 分かりやすくするためにヘッダーを追加
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("FBM Parameters", EditorStyles.boldLabel);
            materialEditor.ShaderProperty(octaves, "Octaves");
            materialEditor.ShaderProperty(lacunarity, "Lacunarity");
            materialEditor.ShaderProperty(gain, "Gain");
        }
    }
}