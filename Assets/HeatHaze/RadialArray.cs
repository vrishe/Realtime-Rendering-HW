using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class RadialArray : MonoBehaviour
{
    public ArrayCircle[] Circles;

    private Dictionary<string, List<GameObject>> _pool = new Dictionary<string, List<GameObject>>();

    private static Action<UnityEngine.Object> GetObjectDestroyFunc() 
        => Application.isEditor ? DestroyImmediate : (Action<UnityEngine.Object>)Destroy;

    private void Update()
    {
        if (Application.isPlaying)
        {
            DestroyImmediate(this);

            return;
        }

        UpdateArray();
    }

    private void UpdateArray()
    {
        if (Circles == null)
            return;

        var circles = new Dictionary<string, List<ArrayCircle>>();
        for (int i = 0; i < Circles.Length; ++i)
        {
            var circle = Circles[i];

            var prefab = circle.ItemPrefab;
            if (!prefab)
                continue;

            var id = AssetDatabase.GetAssetPath(prefab);
            if (!circles.TryGetValue(id, out var circlesList))
            {
                circles[id] = circlesList = new List<ArrayCircle>();
            }

            circlesList.Add(circle);
        }

        foreach (var entry in circles)
        {
            if (!_pool.TryGetValue(entry.Key, out var pool))
            {
                var totalItemsCount = 0;
                for (var i = 0; i < entry.Value.Count; ++i)
                {
                    totalItemsCount += entry.Value[i].ItemsCount;
                }

                _pool[entry.Key] = pool = new List<GameObject>(totalItemsCount);
            }

            for (int i = pool.Count - 1; i >= 0; i--)
            {
                if (!pool[i])
                    pool.RemoveAt(i);
            }

            var k = 0;
            for (var i = 0; i < entry.Value.Count; ++i)
            {
                var circle = entry.Value[i];

                var step = circle.Arc / (circle.ItemsCount + circle.Arc / 360 - 1);
                var angle = circle.RotationOffset;
                for (var j = 0; j < circle.ItemsCount; ++j)
                {
                    var position = new Vector3(
                        circle.PositionOffset.x + circle.Radius * Mathf.Cos(Mathf.Deg2Rad * angle),
                        0,
                        circle.PositionOffset.y + circle.Radius * Mathf.Sin(Mathf.Deg2Rad * angle));

                    angle += step;

                    GameObject instance;

                    if (k < pool.Count)
                    {
                        instance = pool[k];
                    }
                    else
                    {
                        instance = Instantiate(circle.ItemPrefab, transform);

                        pool.Add(instance);
                    }

                    ++k;

                    instance.transform.localPosition = position;
                }
            }

            var destroy = GetObjectDestroyFunc();
            while (k < pool.Count)
            {
                var i = pool.Count - 1;

                destroy(pool[i]);
                pool.RemoveAt(i);
            }
        }
    }

    [Serializable]
    public class ArrayCircle
    {
        [Min(1)]
        public int ItemsCount;

        public GameObject ItemPrefab;

        [Min(0)]
        public float Radius;
        public Vector2 PositionOffset;
        public float RotationOffset;

        [Range(0, 360)]
        public float Arc = 360;
    }
}
