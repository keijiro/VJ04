//
// Infinite scroller for Tunnel.
//

using UnityEngine;
using System.Collections;

namespace Kvant {

[RequireComponent(typeof(Tunnel))]
public class TunnelScroller : MonoBehaviour
{
    float _velocity = 20;
    float _spin = 0.01f;

    public float velocity {
        get { return _velocity; }
        set { _velocity = value; }
    }

    public float spin {
        get { return _spin; }
        set { _spin = value; }
    }

    float position;
    float twist;

    void Update()
    {
        var tunnel = GetComponent<Tunnel>();

        var step = tunnel.height * 2 / tunnel.stacks;

        position += _velocity * Time.deltaTime;
        twist += _spin * Time.deltaTime;

        var frac = position % step;
        transform.localPosition = transform.forward * -frac;

        tunnel.offset = position - frac;
        tunnel.twist = twist;
    }
}

} // namespace Kvant
