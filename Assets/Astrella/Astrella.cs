using UnityEngine;
using System.Collections;

public class Astrella : MonoBehaviour
{
    [Range(0, 1)]
    public float ghostFx = 0;

    [Range(0, 1)]
    public float sliceFx = 0;

    [Range(0, 1)]
    public float emission = 0;

    [Range(0, 1)]
    public float jitterSpeed = 0.5f;

    Renderer[] renderers;

    void Start()
    {
        renderers = GetComponentsInChildren<Renderer>();
    }

    void Update()
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
                m.SetFloat("_Emission", emission * 20);
            }
        }

        JitterJoint.freq = 1.5f * jitterSpeed;
    }
}
