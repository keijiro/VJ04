using UnityEngine;
using System.Collections;

public class FogBgGear : MonoBehaviour
{
    public Reaktion.ReaktorLink reaktor;
    public Gradient gradient;

    void Awake()
    {
        reaktor.Initialize(this);
    }

    void Update()
    {
        var color = gradient.Evaluate(reaktor.Output);
        Camera.main.backgroundColor = color;
        RenderSettings.fogColor = color;
    }
}
