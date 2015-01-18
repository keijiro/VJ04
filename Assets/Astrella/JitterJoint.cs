using UnityEngine;
using System.Collections;

public class JitterJoint : MonoBehaviour
{
    public static float freq = 0.5f;

    public Vector3 limitAngle;
    public JitterJoint linkedTo;

    public Quaternion CurrentRotation {
        get { return currentRotation; }
    }

    Quaternion originalRotation;
    Quaternion currentRotation;
    Vector3 noiseSeed;

    void Awake()
    {
        originalRotation = transform.localRotation;
        noiseSeed = new Vector3(Random.value, Random.value, Random.value) * Mathf.PI;
        currentRotation = Quaternion.identity;
    }

    void Update()
    {
        if (linkedTo)
        {
            currentRotation = linkedTo.CurrentRotation;
        }
        else
        {
            var rx = limitAngle.x * Mathf.PerlinNoise(freq * Time.time, noiseSeed.x);
            var ry = limitAngle.y * Mathf.PerlinNoise(freq * Time.time, noiseSeed.y);
            var rz = limitAngle.z * Mathf.PerlinNoise(freq * Time.time, noiseSeed.z);
            currentRotation = Quaternion.Euler(rx, ry, rz);
        }
        transform.localRotation = currentRotation * originalRotation;
    }
}
