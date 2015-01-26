using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class VJ04GlobalSettings : MonoBehaviour
{
    public Cubemap defaultReflection;
    public float defaultReflectionExposure = 1;
    public float defaultReflectionFresnel = 3;
    public float defaultReflectionRoughness = 1;

    void Start()
    {
        if (!Application.isEditor) Screen.showCursor = false;
    }

    void Update()
    {
        Shader.SetGlobalTexture("_VJ04_EnvTex", defaultReflection);
        Shader.SetGlobalMatrix("_VJ04_EnvMatrix", transform.worldToLocalMatrix);
        Shader.SetGlobalFloat("_VJ04_Exposure", defaultReflectionExposure);
        Shader.SetGlobalFloat("_VJ04_Fresnel", defaultReflectionFresnel);
        Shader.SetGlobalFloat("_VJ04_Roughness", defaultReflectionRoughness);
    }
}
