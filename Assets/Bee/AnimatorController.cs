using UnityEngine;

[RequireComponent(typeof(Animator))]
public class AnimatorController : MonoBehaviour
{
    private Animator _animator;

    private int _currentLayerIdx;

    private void OnEnable()
    {
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.Space))
        {
            if (_animator.IsInTransition(0))
            {
                return;
            }
            
            _animator.SetTrigger("Dissolve");
        }
    }
}
