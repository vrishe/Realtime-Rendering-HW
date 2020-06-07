using UnityEngine;

[ExecuteAlways]
public class AutoToggle : MonoBehaviour
{
    public GameObject[] objects;

    public void OnEnable()
    {
        ChangeObjectsActiveState(false);
    }

    public void OnDisable()
    {
        ChangeObjectsActiveState(true);
    }

    private void ChangeObjectsActiveState(bool active)
    {
        if (objects == null)
        {
            return;
        }

        foreach (var o in objects)
        {
            o.SetActive(active);
        }
    }
}
