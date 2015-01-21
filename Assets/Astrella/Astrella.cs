using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Astrella : MonoBehaviour
{
    #region Public Settings

    // General settings.
    public Transform hipNode;

    // Effect parameters.
    [Range(0, 1)] public float ghostFx = 0;
    [Range(0, 1)] public float sliceFx = 0;
    [Range(0, 1)] public float illuminate = 0;

    // Animation parameters.
    [Range(0, 1)] public float jitterSpeed = 0.5f;

    // Skeletal particle settings.
    public ParticleSystem emitter;
    [Range(0, 1)] public float particleEmission = 0;

    // (These properties are exposed only for communicating with Reaktor.)
    public float GhostFx { set { ghostFx = value; } }
    public float SliceFx { set { sliceFx = value; } }
    public float Illuminate { set { illuminate = value; } }
    public float ParticleEmission { set { particleEmission = value; } }

    #endregion

    #region Private Variables

    // Constants.
    const float emissionPointDensity = 60;
    const float maxEmissionFrequency = 1000;

    // Renference to renderers.
    Renderer[] renderers;

    // Particle emision point array.
    struct EmissionPoint
    {
        public Transform transform;
        public Vector3 position;
        public EmissionPoint(Transform t, Vector3 p)
        {
            this.transform = t;
            this.position = p;
        }
    }
    List<EmissionPoint> emissionPoints;

    // Timer used for particle emission.
    float particleTimer = 0;

    #endregion

    #region Private Methods

    // Apply the effect settings to the renderers.
    void ApplyEffectSettings()
    {
        foreach (var r in renderers)
        {
            foreach (var m in r.materials)
            {
                if (ghostFx > 0)
                {
                    m.EnableKeyword("FX_GHOST");
                    m.DisableKeyword("FX_SLICE");
                    m.SetFloat("_Effects", ghostFx);
                }
                else if (sliceFx > 0)
                {
                    m.DisableKeyword("FX_GHOST");
                    m.EnableKeyword("FX_SLICE");
                    m.SetFloat("_Effects", sliceFx);
                }
                else
                {
                    m.DisableKeyword("FX_GHOST");
                    m.DisableKeyword("FX_SLICE");
                }
                m.SetFloat("_Emission", illuminate * 20);
            }
        }
    }

    // Traverse the hierarchy and pick up emission points.
    void ScanEmissionPointRecursive(Transform node)
    {
        foreach (Transform t in node)
        {
            if (t.name.EndsWith("Point")) return;

            var intvl = 1.0f / (t.localPosition.magnitude * emissionPointDensity);
            for (var p = 0.0f; p < 1.0f; p += intvl)
                emissionPoints.Add(new EmissionPoint(node, t.localPosition * p));

            if (!t.name.EndsWith("Hand")) ScanEmissionPointRecursive(t);
        }
    }

    // Emit a given number of particles on randomly chosen emission points.
    void EmitParticle(int count)
    {
        var p = new ParticleSystem.Particle();

        // Shared settings.
        p.startLifetime = p.lifetime = Random.Range(1.0f, 2.5f);
        p.angularVelocity = 100;
        p.color = Color.white;

        for (var i = 0; i < count; i++)
        {
            // Pick up an emission point from the array.
            var ep = emissionPoints[Random.Range(0, emissionPoints.Count)];

            // Set the position.
            p.position = ep.transform.TransformPoint(ep.position);
            p.position += Random.insideUnitSphere * (2.0f / emissionPointDensity);

            // Random settings.
            p.velocity = Random.insideUnitSphere * 0.5f;
            p.size = Random.Range(0.015f, 0.11f);
            p.axisOfRotation = Random.onUnitSphere;
            p.rotation = Random.Range(-180.0f, 180.0f);

            // Emit one particle.
            emitter.Emit(p);
        }
    }

    #endregion

    #region MonoBehaviour

    void Start()
    {
        renderers = GetComponentsInChildren<Renderer>();

        // Initialize the emission point list.
        emissionPoints = new List<EmissionPoint>();
        ScanEmissionPointRecursive(hipNode);
    }

    void Update()
    {
        // Effects.
        ApplyEffectSettings();

        // Animation.
        JitterJoint.freq = 1.5f * jitterSpeed;

        // Particle emission.
        particleTimer += Time.deltaTime * maxEmissionFrequency * particleEmission;
        var emission = Mathf.FloorToInt(particleTimer);
        EmitParticle(emission);
        particleTimer -= emission;
    }

    #endregion
}
