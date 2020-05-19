using System.Collections.Generic;
using UnityEngine;

public class PlaneGizmo : MonoBehaviour
{
    private Mesh _gizmoMesh;
    private Matrix4x4 _gizmoMatrix;

    public float Size = 1;

    private void PrepareGizmos()
    {
        if (_gizmoMesh != null)
        {
            return;
        }

        _gizmoMatrix = Matrix4x4.Translate(
            -new Vector3(.5f, .5f));

        _gizmoMesh = new Mesh
        {
            subMeshCount = 5,
            vertices = new[] {
                new Vector3(0,0),
                new Vector3(0,1),
                new Vector3(1,1),
                new Vector3(1,0),

                new Vector3(.5f, .375f, .125f),
                new Vector3(.5f, .5f, 0),
                new Vector3(.5f, .625f, .125f),
                new Vector3(.5f, .375f, .375f),
                new Vector3(.5f, .5f, .5f),
                new Vector3(.5f, .625f, .375f),

                new Vector3(.375f, .5f, 0),
                new Vector3(.5f, .625f, 0),
                new Vector3(.625f, .5f, 0),
            },
        };

        _gizmoMesh.SetNormals(new List<Vector3>(System.Linq.Enumerable
            .Repeat(Vector3.forward, _gizmoMesh.vertexCount)));

        // Marker
        _gizmoMesh.SetIndices(new int[] { 5, 8, 7, 8, 8, 9, 10, 11, 11, 12 }, MeshTopology.Lines, 3);

        // Bounds
        _gizmoMesh.SetIndices(new int[] { 0, 1, 1, 2, 2, 3, 3, 0 }, MeshTopology.Lines, 2);
        _gizmoMesh.SetIndices(new int[] { 2, 1, 0, 0, 3, 2 }, MeshTopology.Triangles, 4);

        // Arrows
        _gizmoMesh.SetIndices(new int[] { 8, 5, 4, 5, 5, 6 }, MeshTopology.Lines, 1);
        _gizmoMesh.SetIndices(new int[] { 5, 8, 7, 8, 8, 9 }, MeshTopology.Lines, 0);
    }

    private void OnDrawGizmos()
    {
        PrepareGizmos();

        var m = Matrix4x4.TRS(transform.position, transform.rotation, new Vector3(Size, Size, Size));

        Gizmos.color = Color.cyan;
        Gizmos.matrix = m * _gizmoMatrix;
        Gizmos.DrawWireMesh(_gizmoMesh, 2);

        Gizmos.matrix = Matrix4x4.identity;
        Gizmos.DrawRay(transform.position, Size * transform.forward);
    }
}

