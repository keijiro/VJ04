//
// Custom editor for Tunnel.
//

using UnityEngine;
using UnityEditor;
using System.Collections;

namespace Kvant {

[CustomEditor(typeof(Tunnel))]
public class TunnelEditor : Editor
{
    SerializedProperty propRadius;
    SerializedProperty propHeight;

    SerializedProperty propSlices;
    SerializedProperty propStacks;

    SerializedProperty propOffset;
    SerializedProperty propTwist;

    SerializedProperty propFrequency;
    SerializedProperty propBump;
    SerializedProperty propWarp;

    SerializedProperty propSurfaceColor;
    SerializedProperty propLineColor;
    SerializedProperty propLineColorAmp;

    SerializedProperty propDebug;

    void OnEnable()
    {
        propRadius          = serializedObject.FindProperty("_radius");
        propHeight          = serializedObject.FindProperty("_height");

        propSlices          = serializedObject.FindProperty("_slices");
        propStacks          = serializedObject.FindProperty("_stacks");

        propOffset          = serializedObject.FindProperty("_offset");
        propTwist           = serializedObject.FindProperty("_twist");

        propFrequency       = serializedObject.FindProperty("_frequency");
        propBump            = serializedObject.FindProperty("_bump");
        propWarp            = serializedObject.FindProperty("_warp");

        propSurfaceColor    = serializedObject.FindProperty("_surfaceColor");
        propLineColor       = serializedObject.FindProperty("_lineColor");
        propLineColorAmp    = serializedObject.FindProperty("_lineColorAmp");

        propDebug           = serializedObject.FindProperty("_debug");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(propRadius);
        EditorGUILayout.PropertyField(propHeight);

        EditorGUILayout.Space();

        EditorGUI.BeginChangeCheck();
        EditorGUILayout.PropertyField(propSlices);
        EditorGUILayout.PropertyField(propStacks);
        if (EditorGUI.EndChangeCheck())
            (target as Tunnel).NotifyConfigChanged();

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(propOffset);
        EditorGUILayout.PropertyField(propTwist);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(propFrequency);
        EditorGUILayout.PropertyField(propBump);
        EditorGUILayout.PropertyField(propWarp);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(propSurfaceColor);
        EditorGUILayout.PropertyField(propLineColor);
        EditorGUILayout.Slider(propLineColorAmp, 1.0f, 20.0f);

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(propDebug);

        serializedObject.ApplyModifiedProperties();
    }
}

} // namespace Kvant
