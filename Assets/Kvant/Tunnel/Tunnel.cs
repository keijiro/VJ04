//
// Tunnel - fractal tunnel renderer.
//

using UnityEngine;
using System.Collections;

namespace Kvant {

[ExecuteInEditMode]
[AddComponentMenu("Kvant/Tunnel")]
public partial class Tunnel : MonoBehaviour
{
    #region Parameters Exposed To Editor

    [SerializeField] float _radius = 5;
    [SerializeField] float _height = 20;

    [SerializeField] int _slices = 8;
    [SerializeField] int _stacks = 10;

    [SerializeField] float _offset = 0;
    [SerializeField] float _twist = 0;

    [SerializeField] int _frequency = 2;
    [SerializeField] float _bump = 0;
    [SerializeField] float _warp = 0;

    [SerializeField] Color _surfaceColor = new Color(0.8f, 0.8f, 0.8f, 1);
    [SerializeField] Color _lineColor = new Color(1, 1, 1, 0);
    [SerializeField] float _lineColorAmp = 1;

    [SerializeField] bool _debug;

    #endregion

    #region Public Properties

    public float radius {
        get { return _radius; }
        set { _radius = value; }
    }

    public float height {
        get { return _height; }
        set { _height = value; }
    }

    public int slices { get { return _slices; } }
    public int stacks { get { return _stacks; } }

    public float offset {
        get { return _offset; }
        set { _offset = value; }
    }

    public float twist {
        get { return _twist; }
        set { _twist = value; }
    }

    public int frequency {
        get { return _frequency; }
        set { _frequency = value; }
    }

    public float bump {
        get { return _bump; }
        set { _bump = value; }
    }

    public float warp {
        get { return _warp; }
        set { _warp = value; }
    }

    public Color surfaceColor {
        get { return _surfaceColor; }
        set { _surfaceColor = value; }
    }

    public Color lineColor {
        get { return _lineColor; }
        set { _lineColor = value; }
    }

    public float lineColorAmp {
        get { return _lineColorAmp; }
        set { _lineColorAmp = value; }
    }

    #endregion

    #region Shader And Materials

    [SerializeField] Shader _kernelShader;
    [SerializeField] Shader _surfaceShader;
    [SerializeField] Shader _lineShader;
    [SerializeField] Shader _debugShader;

    Material _kernelMaterial;
    Material _surfaceMaterial1;
    Material _surfaceMaterial2;
    Material _lineMaterial;
    Material _debugMaterial;

    #endregion

    #region GPGPU Buffers

    RenderTexture _positionBuffer;
    RenderTexture _normalBuffer1;
    RenderTexture _normalBuffer2;

    #endregion

    #region Private Objects

    Lattice _lattice;
    bool _needsReset = true;

    #endregion

    #region Resource Management

    public void NotifyConfigChanged()
    {
        _needsReset = true;
    }

    void SanitizeParameters()
    {
        _slices = Mathf.Clamp(_slices, 8, 255);
        _stacks = Mathf.Clamp(_stacks, 8, 1023);
    }

    Material CreateMaterial(Shader shader)
    {
        var material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        return material;
    }

    RenderTexture CreateBuffer()
    {
        var buffer = new RenderTexture(_slices * 2, _stacks + 1, 0, RenderTextureFormat.ARGBFloat);
        buffer.hideFlags = HideFlags.DontSave;
        buffer.filterMode = FilterMode.Point;
        buffer.wrapMode = TextureWrapMode.Repeat;
        return buffer;
    }

    void ApplyKernelParameters()
    {
        var height = _height * (_stacks + 1) / _stacks;
        var vfreq = _frequency / (Mathf.PI * 2 * _radius);
        var nparams = new Vector4(_frequency, vfreq * height, _twist * _frequency, _offset * vfreq);

        _kernelMaterial.SetVector("_SizeParams", new Vector2(_radius, height));
        _kernelMaterial.SetVector("_NoiseParams",nparams);
        _kernelMaterial.SetVector("_NoisePeriod", new Vector3(1, 100000));
        _kernelMaterial.SetVector("_Displace", new Vector3(_bump, _warp, _warp));
    }

    void ResetResources()
    {
        SanitizeParameters();

        // Lattice mesh object.
        if (_lattice == null)
            _lattice = new Lattice(_slices, _stacks);
        else
            _lattice.Rebuild(_slices, _stacks);

        // GPGPU buffers.
        if (_positionBuffer) DestroyImmediate(_positionBuffer);
        if (_normalBuffer1)  DestroyImmediate(_normalBuffer1);
        if (_normalBuffer2)  DestroyImmediate(_normalBuffer2);

        _positionBuffer = CreateBuffer();
        _normalBuffer1  = CreateBuffer();
        _normalBuffer2  = CreateBuffer();

        // Shader materials.
        if (!_kernelMaterial)   _kernelMaterial   = CreateMaterial(_kernelShader);
        if (!_surfaceMaterial1) _surfaceMaterial1 = CreateMaterial(_surfaceShader);
        if (!_surfaceMaterial2) _surfaceMaterial2 = CreateMaterial(_surfaceShader);
        if (!_lineMaterial)     _lineMaterial     = CreateMaterial(_lineShader);
        if (!_debugMaterial)    _debugMaterial    = CreateMaterial(_debugShader);

        // Set buffer references.
        _surfaceMaterial1.SetTexture("_PositionTex", _positionBuffer);
        _surfaceMaterial2.SetTexture("_PositionTex", _positionBuffer);
        _lineMaterial    .SetTexture("_PositionTex", _positionBuffer);
        _surfaceMaterial1.SetTexture("_NormalTex",   _normalBuffer1);
        _surfaceMaterial2.SetTexture("_NormalTex",   _normalBuffer2);

        _needsReset = false;
    }

    #endregion

    #region MonoBehaviour Functions

    void Reset()
    {
        _needsReset = true;
    }

    void OnDestroy()
    {
        if (_lattice != null) _lattice.Release();
        if (_positionBuffer)   DestroyImmediate(_positionBuffer);
        if (_normalBuffer1)    DestroyImmediate(_normalBuffer1);
        if (_normalBuffer2)    DestroyImmediate(_normalBuffer2);
        if (_kernelMaterial)   DestroyImmediate(_kernelMaterial);
        if (_surfaceMaterial1) DestroyImmediate(_surfaceMaterial1);
        if (_surfaceMaterial2) DestroyImmediate(_surfaceMaterial2);
        if (_lineMaterial)     DestroyImmediate(_lineMaterial);
        if (_debugMaterial)    DestroyImmediate(_debugMaterial);
    }

    void Update()
    {
        if (_needsReset) ResetResources();

        ApplyKernelParameters();

        // Update the position buffer and the normal vector buffer with the GPGPU kernels.
        Graphics.Blit(null, _positionBuffer, _kernelMaterial, 0);
        Graphics.Blit(_positionBuffer, _normalBuffer1, _kernelMaterial, 1);
        Graphics.Blit(_positionBuffer, _normalBuffer2, _kernelMaterial, 2);

        // Update the parameters for the surface/line shader.
        _surfaceMaterial1.SetColor("_Color", _surfaceColor);
        _surfaceMaterial2.SetColor("_Color", _surfaceColor);
        _lineMaterial.SetColor("_Color", _lineColor);
        _lineMaterial.SetFloat("_ColorAmp", _lineColorAmp);

        foreach (var mesh in _lattice.meshes)
        {
            Graphics.DrawMesh(mesh, transform.position, transform.rotation, _surfaceMaterial1, 0, null, 0);
            Graphics.DrawMesh(mesh, transform.position, transform.rotation, _surfaceMaterial2, 0, null, 1);
            if (_lineColor.a > 0.0f)
                Graphics.DrawMesh(mesh, transform.position, transform.rotation, _lineMaterial, 0, null, 2);
        }
    }

    void OnGUI()
    {
        if (_debug && Event.current.type.Equals(EventType.Repaint) && _debugMaterial)
        {
            var w = 64;
            var r1 = new Rect(0 * w, 0, w, w);
            var r2 = new Rect(1 * w, 0, w, w);
            var r3 = new Rect(2 * w, 0, w, w);
            if (_positionBuffer) Graphics.DrawTexture(r1, _positionBuffer, _debugMaterial);
            if (_normalBuffer1)  Graphics.DrawTexture(r2, _normalBuffer1,  _debugMaterial);
            if (_normalBuffer2)  Graphics.DrawTexture(r3, _normalBuffer2,  _debugMaterial);
        }
    }

    #endregion
}

} // namespace Kvant
