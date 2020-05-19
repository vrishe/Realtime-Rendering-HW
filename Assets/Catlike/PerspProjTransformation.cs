using UnityEngine;

public class PerspProjTransformation : ProceduralGrid.TransformationBase
{
    public Transform Plane;

    public float FieldOfView = 90;

    public override void Apply(ref Vector3 p)
    {
        p = Plane.InverseTransformDirection(p - Plane.position);

        var f = Mathf.Tan(FieldOfView * Mathf.PI / 360);
        var p1 = new Vector4(p.x/f, p.y/f, 0, p.z);

        p = Plane.position + Plane.TransformVector(p1 / p1.w);
    }
}
