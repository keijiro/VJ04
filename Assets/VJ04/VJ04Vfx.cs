using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class VJ04Vfx : MonoBehaviour
{
    // Noise intensity.
    [Range(0, 1)] [SerializeField] float _noise = 0.5f;

    public float noise {
        get { return _noise; }
        set { _noise = value; }
    }

    // Invert.
    [Range(0, 1)] [SerializeField] float _invert = 0;

    public float invert {
        get { return _invert; }
        set { _invert = value; }
    }

    // Whiteout.
    [Range(0, 1)] [SerializeField] float _whiteout = 0;

    public float whiteout {
        get { return _whiteout; }
        set { _whiteout = value; }
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

        if (_noise > 0.01f || _invert > 0.01f || _whiteout > 0.01f)
        {
            _material.SetFloat("_NoiseThreshold", Mathf.Clamp01(1.0f - _noise * 1.2f));
            _material.SetFloat("_NoiseDisplace", 0.01f + Mathf.Pow(_noise, 3) * 0.1f);
            _material.SetFloat("_Invert", _invert);
            _material.SetFloat("_Whiteout", _whiteout);
            Graphics.Blit(source, destination, _material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
