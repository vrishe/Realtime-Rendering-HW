using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class DissolveProperty : MonoBehaviour
{
    private static readonly int ThresholdPropId = Shader.PropertyToID("_Threshold");

    private MaterialPropertyBlock _props;
    private bool _initialized;

    public Renderer Renderer;
    public float Dissolve;

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
            _props.SetFloat(ThresholdPropId, Mathf.Clamp01(Dissolve));
        }
        Renderer.SetPropertyBlock(_props);
    }
}
