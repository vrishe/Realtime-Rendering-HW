using System;
using UnityEngine;

[ExecuteAlways]
public class ProceduralGrid : MonoBehaviour
{
    public abstract class TransformationBase : MonoBehaviour, ITransformation
    {
        private ProceduralGrid _grid;

        protected TransformationBase()
        {
            /* Nothing to do */
        }

        public abstract void Apply(ref Vector3 p);

        private void Awake()
        {
            _grid = GetComponent<ProceduralGrid>();
            _grid.Transformation = this;
        }

        private void OnDestroy()
        {
            _grid.Transformation = null;
        }
    }

    private static readonly int _colorPropId = Shader.PropertyToID("_Color");

    private readonly ITransformation _nullTransformation = new NullTransformation();

    private int _gridResolutionLast;
    private ITransformation _transformation;

    private Vector3[] _points;
    private Matrix4x4[] _matrices;

    private MaterialPropertyBlock _materialProps;

    public Mesh Prefab;

    public Material Material;

    public int GridResolution = 4;

    [Range(0, 1)]
    public float PointScale = .5f;

    private ITransformation Transformation
    {
        get => _transformation;
        set
        {
            _transformation = value;
            if (_transformation == null)
            {
                _transformation = _nullTransformation;
            }
        }
    }

    private int PointsCount => GridResolution * GridResolution * GridResolution;

    private Vector3 GetCoordinates(int x, int y, int z)
    {
        return new Vector3(
            x - (GridResolution - 1) * 0.5f,
            y - (GridResolution - 1) * 0.5f,
            z - (GridResolution - 1) * 0.5f);
    }

    private void Awake()
    {
        FindGridTransformation();
    }

    private void FindGridTransformation()
    {
        Transformation = GetComponent<ITransformation>();
    }

    private void GenerateGrid()
    {
        _points = new Vector3[PointsCount];
        _matrices = new Matrix4x4[PointsCount];

        var colors = new Vector4[_points.Length];

        int x, y, z;
        for (var i = 0; i < _points.Length; ++i)
        {
            z = Math.DivRem(i, GridResolution * GridResolution, out x);
            y = Math.DivRem(x, GridResolution, out x);

            colors[i].Set(
                x / (float)GridResolution,
                y / (float)GridResolution,
                z / (float)GridResolution,
                1.0f);

            _points[i] = GetCoordinates(x, y, z);
        }

        _materialProps = new MaterialPropertyBlock();
        _materialProps.SetVectorArray(_colorPropId, colors);

        if (Material == null)
        {
            Material = new Material(Shader.Find("Catlike/Grid/SpaceColorShader"));
            Material.enableInstancing = true;
        }
    }

    private void OnEnable()
    {
        FindGridTransformation();
    }

    private void Reset()
    {
        _gridResolutionLast = 0;

        FindGridTransformation();
    }

    private bool TrackChanges()
    {
        GridResolution = Math.Min(Math.Max(GridResolution, 1), 10);

        try
        {
            return _gridResolutionLast != GridResolution;
        }
        finally
        {
            _gridResolutionLast = GridResolution;
        }
    }

    private void Update()
    {
#if UNITY_EDITOR
        if (TrackChanges())
        {
            GenerateGrid();
        }
#endif // UNITY_EDITOR

        var r = new Quaternion(0, 0, 0, 1);
        var s = PointScale * Vector3.one;

        for (var i = 0; i < _points.Length; ++i)
        {
            var t = transform.localToWorldMatrix.MultiplyPoint(_points[i]);

            _transformation.Apply(ref t);
            _matrices[i].SetTRS(t, r, s);
        }

        Graphics.DrawMeshInstanced(Prefab, 0, Material,
            _matrices, _matrices.Length, _materialProps);
    }

    private interface ITransformation
    {
        void Apply(ref Vector3 p);
    }

    private class NullTransformation : ITransformation
    {
        public void Apply(ref Vector3 p)
        {
            /* Nothing to do */
        }
    }
}
