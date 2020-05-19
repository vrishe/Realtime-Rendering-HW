using UnityEngine;

[ExecuteAlways]
public class TransformSynchronizer : MonoBehaviour
{
    public Transform Source;
    public Transform Destination;

    private void Update()
    {
        Destination.localPosition = Source.localPosition;
        Destination.localRotation = Source.localRotation;
        Destination.localScale = Source.localScale;
    }
}