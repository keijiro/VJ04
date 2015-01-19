using UnityEngine;
using System.Collections;

public class JitterJoint : MonoBehaviour
{
    public static float freq = 0.7f;

    public Vector3 limitAngle;
    public JitterJoint linkedTo;

    public Quaternion CurrentRotation {
        get { return currentRotation; }
    }

    Quaternion originalRotation;
    Quaternion currentRotation;
    Vector3 noiseSeed;
    float time;

    void Awake()
    {
        originalRotation = transform.localRotation;
        noiseSeed = new Vector3(Random.value, Random.value, Random.value) * Mathf.PI * 10;
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
            time += Time.deltaTime * freq;
            var rx = limitAngle.x * Mathf.PerlinNoise(time, noiseSeed.x);
            var ry = limitAngle.y * Mathf.PerlinNoise(time, noiseSeed.y);
            var rz = limitAngle.z * Mathf.PerlinNoise(time, noiseSeed.z);
            currentRotation = Quaternion.Euler(rx, ry, rz);
        }
        transform.localRotation = currentRotation * originalRotation;
    }
}
