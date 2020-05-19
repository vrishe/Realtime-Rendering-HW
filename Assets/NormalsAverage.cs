using System;
using System.Collections.Generic;
using UnityEngine;

class NormalsAverage
{
    const double DecimalPlacesBase = 1000.0;

    private readonly IDictionary<Vector3, AccumulatorSlot> _accumulator =
        new Dictionary<Vector3, AccumulatorSlot>();
    private readonly List<Vector3> _normals = new List<Vector3>();
    private readonly List<int> _triangles = new List<int>();
    private readonly List<Vector3> _vertices = new List<Vector3>();

    public void Find(Mesh mesh)
    {
        var places = CalculateDecimalPlaces(mesh.bounds);
        mesh.GetVertices(_vertices);
        {
            var vert = Vector3.zero;
            for (var i = 0; i < _vertices.Count; ++i)
            {
                var v = _vertices[i];

                vert.x = (float)(Math.Round(v.x * places) / places);
                vert.y = (float)(Math.Round(v.y * places) / places);
                vert.z = (float)(Math.Round(v.z * places) / places);

                _vertices[i] = vert;
            }
        }

        mesh.GetNormals(_normals);

        for (int i = 0; i < mesh.subMeshCount; ++i)
        {
            mesh.GetTriangles(_triangles, i);
            for (var j = 0; j < _triangles.Count; ++j)
            {
                var k = _triangles[j];
                var key = _vertices[k];

                if (!_accumulator.TryGetValue(key, out var slot))
                {
                    slot = _accumulator[key] = new AccumulatorSlot();
                }

                slot.Add(k, _normals[k]);
            }

            _triangles.Clear();
        }

        _vertices.Clear();

        foreach (var slot in _accumulator.Values)
        {
            Vector3 value = slot.Value;
            foreach (var i in slot.Indices)
            {
                _normals[i] = value;
            }
        }

        _accumulator.Clear();

        mesh.SetNormals(_normals);
        _normals.Clear();
    }

    private static double CalculateDecimalPlaces(Bounds bounds)
    {
        var result = DecimalPlacesBase;

        var extents = bounds.extents;
        var value = Math.Abs((double)Mathf.Min(extents.x, extents.y, extents.z));

        while (((int)(value *= 10)) == 0)
        {
            result *= 10;
        }

        return result;
    }

    private class AccumulatorSlot
    {
        private int _count = 0;
        private Vector3 _value = Vector3.zero;

        public ISet<int> Indices { get; } = new HashSet<int>();

        public Vector3 Value
        {
            get => _value / _count;
            set
            {
                _count = 1;
                _value = value;
            }
        }

        public void Add(int idx, Vector3 value)
        {
            if (!Indices.Add(idx))
            {
                return;
            }

            ++_count;
            _value += value;
        }
    }
}
