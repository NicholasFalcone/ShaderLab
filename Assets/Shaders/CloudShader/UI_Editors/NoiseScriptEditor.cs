﻿using UnityEditor;
using UnityEngine;
using UnityEditor.Experimental.AssetImporters;

[CustomEditor(typeof(NoiseGenerator))]
[CanEditMultipleObjects]
public class NoiseScriptEditor : Editor
{
    // compute shaders needed for the noise script to work
    private SerializedProperty slicer;
    private SerializedProperty NoiseTextureGenerator;


    // perlin settings for the shape noise texture
    private SerializedProperty shapePerlinOctaves; // 8 by default
    private SerializedProperty shapePerlinFrequency; // 1 by default
    private SerializedProperty shapePerlinPersistence; // 0.6 by default
    private SerializedProperty shapePerlinLacunarity; // 2 by default
    private SerializedProperty shapePerlinTextureResolution; // 16 by default


    // worley settings for other three channels of the shape noise texture
    private SerializedProperty shapeGreenChannelOctaves;
    private SerializedProperty shapeBlueChannelOctaves;
    private SerializedProperty shapeAlphaChannelOctaves;
    private SerializedProperty shapeGreenChannelCellSize;
    private SerializedProperty shapeBlueChannelCellSize;
    private SerializedProperty shapeAlphaChannelCellSize;

    
    // worley settings for the detail noise texture
    private SerializedProperty detailGreenChannelOctaves;
    private SerializedProperty detailBlueChannelOctaves;
    private SerializedProperty detailRedChannelOctaves;
    private SerializedProperty detailGreenChannelCellSize;
    private SerializedProperty detailBlueChannelCellSize;
    private SerializedProperty detailRedChannelCellSize;

    // weather map settings
    private SerializedProperty weatherMap;
    private SerializedProperty coverageOption;
    private SerializedProperty coverageConstant;
    private SerializedProperty cloudHeight;
    private SerializedProperty cloudType;

    // weather map perlin settings
    private SerializedProperty coveragePerlinOctaves; // 8 by default
    private SerializedProperty coveragePerlinFrequency; // 1 by default
    private SerializedProperty coveragePerlinPersistence; // 0.6 by default
    private SerializedProperty coveragePerlinLacunarity; // 2 by default
    private SerializedProperty coveragePerlinTextureResolution; // 128 by default

    private void OnEnable()
    {
        // the compute shaders
        NoiseTextureGenerator = serializedObject.FindProperty("NoiseTextureGenerator");
        slicer = serializedObject.FindProperty("slicer");

        // perlin settings (red channel) of the shape texture
        shapePerlinTextureResolution = serializedObject.FindProperty("shapePerlinTextureResolution");
        shapePerlinOctaves = serializedObject.FindProperty("shapePerlinOctaves");
        shapePerlinFrequency = serializedObject.FindProperty("shapePerlinFrequency");
        shapePerlinPersistence = serializedObject.FindProperty("shapePerlinPersistence");
        shapePerlinLacunarity = serializedObject.FindProperty("shapePerlinLacunarity");

        // worley settings of the shape texture
        shapeGreenChannelOctaves = serializedObject.FindProperty("shapeGreenChannelOctaves");
        shapeBlueChannelOctaves = serializedObject.FindProperty("shapeBlueChannelOctaves");
        shapeAlphaChannelOctaves = serializedObject.FindProperty("shapeAlphaChannelOctaves");
        shapeGreenChannelCellSize = serializedObject.FindProperty("shapeGreenChannelCellSize");
        shapeBlueChannelCellSize = serializedObject.FindProperty("shapeBlueChannelCellSize");
        shapeAlphaChannelCellSize = serializedObject.FindProperty("shapeAlphaChannelCellSize");

        // worley settings of the detail texture
        detailGreenChannelOctaves = serializedObject.FindProperty("detailGreenChannelOctaves");
        detailBlueChannelOctaves = serializedObject.FindProperty("detailBlueChannelOctaves");
        detailRedChannelOctaves = serializedObject.FindProperty("detailRedChannelOctaves");
        detailGreenChannelCellSize = serializedObject.FindProperty("detailGreenChannelCellSize");
        detailBlueChannelCellSize = serializedObject.FindProperty("detailBlueChannelCellSize");
        detailRedChannelCellSize = serializedObject.FindProperty("detailRedChannelCellSize");

        // weather map settings
        weatherMap = serializedObject.FindProperty("weatherMap");
        coverageOption = serializedObject.FindProperty("coverageOption");
        coverageConstant = serializedObject.FindProperty("coverageConstant");
        coveragePerlinOctaves = serializedObject.FindProperty("coveragePerlinOctaves");
        coveragePerlinFrequency = serializedObject.FindProperty("coveragePerlinFrequency");
        coveragePerlinPersistence = serializedObject.FindProperty("coveragePerlinPersistence");
        coveragePerlinLacunarity = serializedObject.FindProperty("coveragePerlinLacunarity");
        coveragePerlinTextureResolution = serializedObject.FindProperty("coveragePerlinTextureResolution");
        cloudHeight = serializedObject.FindProperty("cloudHeight");
        cloudType = serializedObject.FindProperty("cloudType");
    }

    // draw a line in the UI editor
    public static void DrawUILine(Color color, int thickness = 2, int padding = 10)
    {
        Rect r = EditorGUILayout.GetControlRect(GUILayout.Height(padding+thickness));
        r.height = thickness;
        r.y+=padding/2;
        r.x-=30;
        r.width +=36;
        EditorGUI.DrawRect(r, color);
    }

    public override void OnInspectorGUI() 
    {
        serializedObject.Update();
        EditorGUILayout.Space();

        // the compute shaders needed for the script to work
        EditorGUILayout.PropertyField(NoiseTextureGenerator);
        EditorGUILayout.PropertyField(slicer);

        // draw a line between compute shader settings and shape noise settings
        EditorGUILayout.Space();
        DrawUILine(new Color((float)0.5,(float)0.5,(float)0.5,1), 1, 10);
        
        // perlin noise options
        EditorGUILayout.LabelField("Shape Noise", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("Perlin Noise");
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("Red Channel");
        EditorGUI.indentLevel++;
        string[] textureResolutionOptionNames = {"4","8","16", "32", "64"};
        int[] textureResolutionOptionValues = {4,8,16, 32, 64};
        shapePerlinTextureResolution.intValue = EditorGUILayout.IntPopup("Resolution", shapePerlinTextureResolution.intValue, textureResolutionOptionNames, textureResolutionOptionValues);
        EditorGUILayout.IntSlider(shapePerlinOctaves, 1, 8, "Octaves");
        EditorGUILayout.PropertyField(shapePerlinFrequency, new GUIContent("Frequency"));
        EditorGUILayout.Slider(shapePerlinPersistence, 0, 1, new GUIContent("Persistence"));
        EditorGUILayout.IntSlider(shapePerlinLacunarity, 1, 5, new GUIContent("Lacunarity"));
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel--;

        // worley noise options for channels
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Worley Noise");
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("Green Channel");
        // add octaves, add cellSize
        EditorGUI.indentLevel++;
        EditorGUILayout.IntSlider(shapeGreenChannelOctaves, 1, 8,"Octaves");
        string[] shapeCellOptionNames = {"4","8","16", "32", "64"};
        int[] shapeCellOptionValues = {4,8,16,32,64};
        shapeGreenChannelCellSize.intValue = EditorGUILayout.IntPopup("Cell Size", shapeGreenChannelCellSize.intValue,shapeCellOptionNames, shapeCellOptionValues);
        EditorGUI.indentLevel--;

        EditorGUILayout.LabelField("Blue Channel");
        EditorGUI.indentLevel++;
        EditorGUILayout.IntSlider(shapeBlueChannelOctaves, 1, 8,"Octaves");
        shapeBlueChannelCellSize.intValue = EditorGUILayout.IntPopup("Cell Size", shapeBlueChannelCellSize.intValue,shapeCellOptionNames,shapeCellOptionValues);
        EditorGUI.indentLevel--;

        EditorGUILayout.LabelField("Alpha Channel");
        EditorGUI.indentLevel++;
        EditorGUILayout.IntSlider(shapeAlphaChannelOctaves, 1, 8,"Octaves");
        shapeAlphaChannelCellSize.intValue = EditorGUILayout.IntPopup("Cell Size", shapeAlphaChannelCellSize.intValue,shapeCellOptionNames, shapeCellOptionValues);
        EditorGUI.indentLevel--;
        EditorGUILayout.Space();

        // add a button to create shape texture
        GUILayout.BeginHorizontal();
        GUILayout.Space(Screen.width/2 - 150/2);
        if (GUILayout.Button("Create Shape Texture",GUILayout.Width(150), GUILayout.Height(30)))
        {
            FindObjectOfType<NoiseGenerator>().createShapeNoise();
        }
        GUILayout.EndHorizontal();
        EditorGUILayout.Space();
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel--;

        // draw a line between detail and shape noise settings
        DrawUILine(new Color((float)0.5,(float)0.5,(float)0.5,1), 1, 10);
        
        // start of the detail noise
        EditorGUILayout.LabelField("Detail Noise", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("Worley Noise");
        EditorGUI.indentLevel++;

        // the individual detail noise channels
        string[] detailCellOptionNames = {"2", "4","8","16"};
        int[] detailCellOptionValues = {2, 4,8,16};
        EditorGUILayout.LabelField("Red Channel");
        EditorGUI.indentLevel++;
        EditorGUILayout.IntSlider(detailRedChannelOctaves, 1, 8,"Octaves");
        detailRedChannelCellSize.intValue = EditorGUILayout.IntPopup("Cell Size", detailRedChannelCellSize.intValue,detailCellOptionNames, detailCellOptionValues);
        EditorGUI.indentLevel--;
        EditorGUILayout.LabelField("Green Channel");
        EditorGUI.indentLevel++;
        EditorGUILayout.IntSlider(detailGreenChannelOctaves, 1, 8,"Octaves");
        detailGreenChannelCellSize.intValue = EditorGUILayout.IntPopup("Cell Size", detailGreenChannelCellSize.intValue,detailCellOptionNames, detailCellOptionValues);
        EditorGUI.indentLevel--;
        EditorGUILayout.LabelField("Blue Channel");
        EditorGUI.indentLevel++;
        EditorGUILayout.IntSlider(detailBlueChannelOctaves, 1, 8,"Octaves");
        detailBlueChannelCellSize.intValue = EditorGUILayout.IntPopup("Cell Size", detailBlueChannelCellSize.intValue,detailCellOptionNames, detailCellOptionValues);
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel--;
        EditorGUILayout.Space();

        // add the create detail noise button
        GUILayout.BeginHorizontal();
        GUILayout.Space(Screen.width/2 - 150/2);
        if (GUILayout.Button("Create Detail Texture",GUILayout.Width(150), GUILayout.Height(30)))
        {
            FindObjectOfType<NoiseGenerator>().createDetailNoise();
        }
        GUILayout.EndHorizontal();
        EditorGUILayout.Space();

        // draw a line between detail noise and weather map
        DrawUILine(new Color((float)0.5,(float)0.5,(float)0.5,1), 1, 10);
        
        // start of the weather map
        EditorGUILayout.LabelField("Weather Map", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;

        // weather map red channel options
        string[] cloudCoverageOptionNames = {"Constant","Perlin"};
        int[] cloudCoverageOptionValues = {0,1};
        coverageOption.intValue = EditorGUILayout.IntPopup("Cloud Coverage", coverageOption.intValue, cloudCoverageOptionNames, cloudCoverageOptionValues);
        if (coverageOption.intValue == 0)
        {
            // if constant is chosen for weather map
            EditorGUI.indentLevel++;
            EditorGUILayout.Slider(coverageConstant, 0, 1, new GUIContent("Coverage Value"));
            EditorGUI.indentLevel--;
        }
        else
        {
            // if perlin option is chosen for weather map
            EditorGUI.indentLevel++;
            string[] wmTexResolutionOptionNames = {"1","2","4","8","16","32","64","128","256","512"};
            int[] wmTexResolutionOptionValues = {1,2,4,8,16,32,64,128,256,512};
            coveragePerlinTextureResolution.intValue = EditorGUILayout.IntPopup("Resolution", coveragePerlinTextureResolution.intValue, wmTexResolutionOptionNames, wmTexResolutionOptionValues);
            EditorGUILayout.IntSlider(coveragePerlinOctaves, 1, 8, "Octaves");
            EditorGUILayout.PropertyField(coveragePerlinFrequency, new GUIContent("Frequency"));
            EditorGUILayout.Slider(coveragePerlinPersistence, 0, 1, new GUIContent("Persistence"));
            EditorGUILayout.IntSlider(coveragePerlinLacunarity, 1, 5, new GUIContent("Lacunarity"));  
            EditorGUI.indentLevel--; 
        }

        // other channels of the weather maps
        EditorGUILayout.Slider(cloudHeight, 400, 1000, new GUIContent("Cloud Height (m)"));
        EditorGUILayout.Slider(cloudType, 0, 1, new GUIContent("Cloud Type"));
        EditorGUILayout.Space();

        EditorGUI.indentLevel--;
        EditorGUI.indentLevel--;
        
        // create weather map button
        GUILayout.BeginHorizontal();
        GUILayout.Space(Screen.width/2 - 150/2);
        if (GUILayout.Button("Create Weather Map",GUILayout.Width(150), GUILayout.Height(30)))
        {
            FindObjectOfType<NoiseGenerator>().createWeatherMap();
        }
        GUILayout.EndHorizontal();
        EditorGUILayout.Space();

        serializedObject.ApplyModifiedProperties();
    }

}
 