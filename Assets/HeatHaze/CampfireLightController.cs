using UnityEngine;

[RequireComponent(typeof(Light))]
public class CampfireLightController : MonoBehaviour
{
    public Vector2 OffsetAmplitude;
    public float IntensityAmplitude;
    public float RangeAmplitude;
    public float Response;
    public bool UnscaledTime;

    private Light _light;

    private Vector3 _position, _positionEffective;
    private float _bounceIntensity, _bounceIntensityEffective;
    private float _intensity, _intensityEffective;
    private float _range, _rangeEffective;

    private float _time, _timeStart;

    private float UniformTime => UnscaledTime ? Time.unscaledTime : Time.time;

    private void OnEnable()
    {
        _light = GetComponent<Light>();

        _positionEffective = _position = transform.localPosition;
        _intensityEffective = _intensity = _light.intensity;
        _bounceIntensityEffective = _bounceIntensity = _light.bounceIntensity;
        _rangeEffective = _range = _light.range;
    }

    private void OnDisable()
    {
        transform.localPosition = _positionEffective = _position;
        _light.intensity = _intensityEffective = _intensity;
        _light.bounceIntensity = _bounceIntensityEffective = _bounceIntensity;
        _light.range = _rangeEffective = _range;
    }

    private void Update()
    {
        _time = UniformTime;
        
        var t = (_time - _timeStart) / (Random.value * Response);

        if (t > 1)
        {
            t = 0;

            var offset = .5f * OffsetAmplitude * Random.insideUnitCircle;
            _positionEffective = _position + new Vector3(offset.x, 0, offset.y);
            _bounceIntensityEffective = _bounceIntensity + IntensityAmplitude * (Random.value - .5f);
            _intensityEffective = _intensity + IntensityAmplitude * (Random.value - .5f);
            _rangeEffective = _range + RangeAmplitude * (Random.value - .5f);

            _timeStart = _time;
        }

        transform.localPosition = Vector3.LerpUnclamped(transform.localPosition, _positionEffective, t);
        _light.intensity = Mathf.LerpUnclamped(_light.intensity, _intensityEffective, t);
        _light.bounceIntensity = Mathf.LerpUnclamped(_light.bounceIntensity, _bounceIntensityEffective, t);
        _light.range = Mathf.LerpUnclamped(_light.range, _rangeEffective, t);
    }
}
