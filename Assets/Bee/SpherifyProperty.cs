using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class SpherifyProperty : MonoBehaviour
{
    private static readonly int AmountPropId = Shader.PropertyToID("_Amount");
    private static readonly int RadiusPropId = Shader.PropertyToID("_Radius");

    private MaterialPropertyBlock _props;
    private bool _initialized;

    public Renderer Renderer;
    public float Amount;
    public float Radius;

    private void Init()
    {
        _props = new MaterialPropertyBlock();

        Renderer = GetComponent<Renderer>();
    }

    private void Awake()
    {
        Init();
    }

#if UNITY_EDITOR
    private void OnEnable()
    {
        if (!Application.isPlaying)
        {
            Init();
        }
    }
#endif // UNITY_EDITOR

    private void Update()
    {
        Renderer.GetPropertyBlock(_props);
        {
            _props.SetFloat(AmountPropId, Mathf.Clamp01(Amount));
            _props.SetFloat(RadiusPropId, Radius);
        }
        Renderer.SetPropertyBlock(_props);
    }
}
