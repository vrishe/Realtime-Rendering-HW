using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CameraController : MonoBehaviour
{
    private const float MinDistance = 0.01f;

    private const float DistanceChangeStep = 0.15f;
    private const float DistanceChangeDuration = 0.128f; // Seconds

    private const float ThetaMin = -89; // Degrees
    private const float ThetaMax = 89;

    private bool _active;
    private Camera _camera;
    private Vector3 _positionSnapshot;

    private bool _scrolling;
    private float _nextVal, _prevVal;
    private float _duration;

    public Transform _lookAtTransform;
    public bool _track;

    [Min(MinDistance)] // MinAttribute is not working up to Unity 2020
    public float _distance = 1;

    public AnimationCurve _scrollCurve;

    public float _phi;

    [Range(ThetaMin, ThetaMax)]
    public float _theta;
    [Range(ThetaMin, 0)]
    public float _thetaMin = ThetaMin;
    [Range(0, ThetaMax)]
    public float _thetaMax = ThetaMax;

    private float MaxCameraDistance => .5f*_camera.farClipPlane;
    private float MinCameraDistance => 2*_camera.nearClipPlane;

    private float ClampDistanceLow(float value)
    {
        return Mathf.Max(Mathf.Min(value, MaxCameraDistance),
            MinCameraDistance, MinDistance);
    }

    private void OnEnable()
    {
        _camera = GetComponent<Camera>();

        _positionSnapshot = _lookAtTransform.position;
        if (!Application.isPlaying)
        {
            UpdateCameraPositionAndRotation();
        }
    }

    private void Update()
    {
        if (_track)
        {
            _positionSnapshot = _lookAtTransform.position;
        }

        UpdateCameraPositionAndRotation();

        if (!_active)
        {
            if (Input.GetMouseButtonDown(0))
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = true;

                _active = true;
            }

            Input.ResetInputAxes();

            return;
        }

        var np = _distance / _camera.nearClipPlane;

        _phi = (_phi - np * Input.GetAxisRaw("Mouse X")) % 360;
        _theta = Mathf.Clamp(_theta - np * Input.GetAxisRaw("Mouse Y"), _thetaMin, _thetaMax);

        UpdateMouseScrollDistance();

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;

            _active = false;
            Input.ResetInputAxes();
        }
    }

    private void UpdateCameraPositionAndRotation()
    {
        _distance = ClampDistanceLow(_distance);

#if UNITY_EDITOR
        _theta = Mathf.Clamp(_theta, _thetaMin, _thetaMax);
#endif

        var m = Matrix4x4.Translate(_positionSnapshot)
            * Matrix4x4.Rotate(Quaternion.Euler(_theta, _phi, 0))
            * Matrix4x4.Translate(new Vector3(0, 0, -_distance));

        transform.SetPositionAndRotation(
            m.MultiplyPoint(Vector3.zero),
            m.rotation);
    }

    private void UpdateMouseScrollDistance()
    {
        var scrollAxis = Input.GetAxisRaw("Mouse ScrollWheel");
        var keyScroll = (Input.GetKey(KeyCode.KeypadPlus) ? 1 : 0) - (Input.GetKey(KeyCode.KeypadMinus) ? 1 : 0);

        scrollAxis += keyScroll - 2 * scrollAxis * keyScroll;

        if (scrollAxis != 0)
        {
            var scrollDir = -Mathf.Sign(scrollAxis);

            if (MaxCameraDistance > _nextVal && _nextVal > MinCameraDistance
                && Mathf.Sign(_nextVal - _distance) == scrollDir)
            {
                _distance = _nextVal;
            }

            _duration = 0;
            _prevVal = _distance;
            _nextVal = ClampDistanceLow(_prevVal + scrollDir * DistanceChangeStep);

            _scrolling = true;
        }

        if (!_scrolling)
        {
            return;
        }

        var t = Mathf.Clamp01(_duration / DistanceChangeDuration);
        var s = Mathf.Clamp(_scrollCurve.Evaluate(t), -1, 1);

        _distance = Mathf.Lerp(_prevVal, _nextVal, s);

        if (t >= 1)
        {
            _scrolling = false;
        }
        else
        {
            _duration += Time.unscaledDeltaTime;
        }
    }
}
