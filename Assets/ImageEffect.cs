using UnityEngine;

[ExecuteAlways]
public class ImageEffect : MonoBehaviour
{
    private const int PassDefault = -1;

    [SerializeField]
    public Material material;

    public int pass = PassDefault;

#if UNITY_EDITOR
    private void Update()
    {
        if (pass >= material.passCount)
        {
            pass = material.passCount - 1;
        }
        else if (pass < PassDefault)
        {
            pass = PassDefault;
        }
    }
#endif // UNITY_EDITOR

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            Graphics.Blit(source, destination, material, pass);
        }
    }
}
