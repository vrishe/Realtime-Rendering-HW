using UnityEngine;

public class OrthoProjTransformation : ProceduralGrid.TransformationBase
{
    public Transform Plane;

    public override void Apply(ref Vector3 p)
    {
        p = Plane.InverseTransformDirection(p - Plane.position);
        p.z = 0;
        
        p = Plane.position + Plane.TransformDirection(p);
    }
}
