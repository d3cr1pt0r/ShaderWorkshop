using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectorController : MonoBehaviour {

    [SerializeField] private Transform debugCube = null;
    [SerializeField] private float projectorDistance = 1.0f;

    private int projectionMatrixID;

    private void Awake()
    {
        projectionMatrixID = Shader.PropertyToID("_ProjectionMatrix");
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit raycastHit;

            if (Physics.Raycast(ray, out raycastHit, 100.0f))
            {
                Vector3 projectorPosition = raycastHit.point + raycastHit.normal * projectorDistance;

                debugCube.position = projectorPosition;
                debugCube.LookAt(raycastHit.point);

                Shader.SetGlobalMatrix(projectionMatrixID, debugCube.worldToLocalMatrix);
            }
        }
    }
	
}
