using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ScanlineFx : MonoBehaviour
{
    // Effect intensity.
    [Range(0, 1)]
    [SerializeField]
    float _intensity = 0.5f;

    public float intensity {
        get { return _intensity; }
        set { _intensity = value; }
    }

    // Shader and material instance.
    [SerializeField] Shader _shader;
    Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null) {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.DontSave;
        }

        if (_intensity > 0)
        {
            _material.SetFloat("_Threshold", Mathf.Clamp01(1.0f - _intensity * 1.2f));
            _material.SetFloat("_Displace", 0.01f + Mathf.Pow(_intensity, 3) * 0.1f);
            Graphics.Blit(source, destination, _material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
