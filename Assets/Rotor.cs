using UnityEngine;

public class Rotor : MonoBehaviour
{
    public Vector3 _axis;

    public float _velocity;

    void Update()
    {
        transform.localRotation *= Quaternion.AngleAxis(Time.deltaTime * _velocity, _axis);
    }
}
