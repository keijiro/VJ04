
#pragma strict

@CustomEditor (Vignetting)
class VignettingEditor extends Editor 
{	
	var serObj : SerializedObject;	
		
  var mode : SerializedProperty;
  var intensity : SerializedProperty; // intensity == 0 disables pre pass (optimization)
  var curveCoeff : SerializedProperty;
  var chromaticAberration : SerializedProperty;
  var axialAberration : SerializedProperty;
  var blurDistance : SerializedProperty;
  var luminanceDependency : SerializedProperty;

	function OnEnable () {
		serObj = new SerializedObject (target);
		
    mode = serObj.FindProperty ("mode");
    intensity = serObj.FindProperty ("intensity");
    curveCoeff = serObj.FindProperty ("curveCoeff");
    chromaticAberration = serObj.FindProperty ("chromaticAberration");
    axialAberration = serObj.FindProperty ("axialAberration");
    luminanceDependency = serObj.FindProperty ("luminanceDependency");
    blurDistance = serObj.FindProperty ("blurDistance");
	} 
    		
  function OnInspectorGUI () {         
    serObj.Update ();
        	    	
    EditorGUILayout.LabelField("Simulates the common lens artifacts 'Vignette' and 'Aberration'", EditorStyles.miniLabel);

    EditorGUILayout.PropertyField (intensity, new GUIContent("Vignetting"));    
    EditorGUILayout.Slider (curveCoeff, 0.1, 1.0, new GUIContent("Curve Coeff."));    

    EditorGUILayout.Separator ();

    EditorGUILayout.PropertyField (mode, new GUIContent("Aberration"));
    if(mode.intValue>0)  
    {
      EditorGUILayout.PropertyField (chromaticAberration, new GUIContent("  Tangential Aberration"));
      EditorGUILayout.PropertyField (axialAberration, new GUIContent("  Axial Aberration"));
      luminanceDependency.floatValue = EditorGUILayout.Slider("  Contrast Dependency", luminanceDependency.floatValue, 0.001f, 1.0f);
      blurDistance.floatValue = EditorGUILayout.Slider("  Blur Distance", blurDistance.floatValue, 0.001f, 5.0f);
    }
    else
      EditorGUILayout.PropertyField (chromaticAberration, new GUIContent(" Chromatic Aberration"));
        	
    serObj.ApplyModifiedProperties();
    }
}
