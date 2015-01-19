using UnityEngine;
using System.Collections;

public class SprayEmitterUtil : MonoBehaviour
{
    public Transform snapTo;

    void Update()
    {
        var spray = GetComponent<Kvant.Spray>();

        if (snapTo) spray.emitterPosition = snapTo.position;
    }
}
