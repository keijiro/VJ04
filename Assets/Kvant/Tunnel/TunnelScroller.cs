//
// Infinite scroller for Tunnel.
//

using UnityEngine;
using System.Collections;

namespace Kvant {

[RequireComponent(typeof(Tunnel))]
public class TunnelScroller : MonoBehaviour
{
    public float velocity = 2;
    public float spin = 0.01f;

    float position;
    float twist;

    void Update()
    {
        var tunnel = GetComponent<Tunnel>();

        var step = tunnel.height * 2 / tunnel.stacks;

        position += velocity * Time.deltaTime;
        twist += spin * Time.deltaTime;

        transform.localPosition = transform.forward * -(position % step);

        tunnel.offset = Mathf.Floor(position / step) * step;
        tunnel.twist = twist;
    }
}

} // namespace Kvant
