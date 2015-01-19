using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class VJ04GlobalSettings : MonoBehaviour
{
    public Cubemap defaultReflection;
    public float defaultReflectionExposure = 1;

    void Update()
    {
        Shader.SetGlobalTexture("_VJ04_EnvTex", defaultReflection);
        Shader.SetGlobalFloat("_VJ04_Exposure", defaultReflectionExposure);
    }
}
