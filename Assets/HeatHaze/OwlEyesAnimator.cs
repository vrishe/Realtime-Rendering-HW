using System.Collections;
using UnityEngine;

public class OwlEyesAnimator : MonoBehaviour
{
    private const int StateOpen = 0;
    private const int StateClosing = 1;
    private const int StateClosed = 2;
    private const int StateOpening = 3;

    private static readonly int _emissionColorId = Shader.PropertyToID("_EmissionColor");

    public float OpenDuration;
    public float ClosingDuration;
    public float ClosedDuration;
    public float OpeningDuration;

    private MaterialPropertyBlock _property;
    private Renderer _renderer;
    private Vector4 _emissionColor;

    private int _state;
    private Coroutine _coro;

    private void Awake()
    {
        _property = new MaterialPropertyBlock();
    }

    private void OnEnable()
    {
        _renderer = GetComponent<Renderer>();
        _emissionColor = _renderer.sharedMaterial.GetVector(_emissionColorId);
        _coro = StartCoroutine(ScheduleNextAction());
    }

    private void OnDisable()
    {
        StopCoroutine(_coro);
    }

    private IEnumerator ScheduleNextAction()
    {
        float duration, total;

        while (true)
        {
            switch (_state)
            {
                case StateOpen:
                    yield return new WaitForSeconds(OpeningDuration);
                    _state = StateClosing;
                    break;
                case StateClosing:
                    duration = total = ClosingDuration;
                    while (duration >= 0)
                    {
                        _property.SetVector(_emissionColorId, Vector4.Lerp(Vector4.zero, _emissionColor, duration / total));
                        _renderer.SetPropertyBlock(_property, 0);

                        yield return null;
                        duration -= Time.deltaTime;
                    }
                    _state = StateClosed;
                    break;
                case StateClosed:
                    yield return new WaitForSeconds(ClosedDuration);
                    _state = StateOpening;
                    break;
                case StateOpening:
                    duration = total = OpeningDuration;
                    while (duration >= 0)
                    {
                        _property.SetVector(_emissionColorId, Vector4.Lerp(_emissionColor, Vector4.zero, duration / total));
                        _renderer.SetPropertyBlock(_property, 0);

                        yield return null;
                        duration -= Time.deltaTime;
                    }
                    _state = StateOpen;
                    break;
                default:
                    yield break;
            }
        }
    }
}
