using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour
{
    public Transform[] snapPoints;
    public int selection;

    void Update()
    {
        var t = snapPoints[selection];

        var coeff = Mathf.Exp(-2.0f * Time.deltaTime);

        transform.position = Vector3.Lerp(t.position, transform.position, coeff);

        if (transform.rotation != t.rotation)
            transform.rotation = Quaternion.Slerp(t.rotation, transform.rotation, coeff);
    }

    public void ChangeTarget(int index)
    {
        selection = index;
    }
}
