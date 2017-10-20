using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleRotationController : MonoBehaviour {

    [SerializeField] public float speed = 1.0f;

    private Quaternion originalRotation;
    private bool dirty;

    public void Awake() {
        originalRotation = transform.rotation;
    }

    public void OnEnable() {
        transform.rotation = originalRotation;
    }

    public void OnDisable() {
        transform.rotation = originalRotation;
    }

    public void Update() {
        transform.Rotate(0.0f, 0.0f, Time.deltaTime * speed);
    }
	
}
