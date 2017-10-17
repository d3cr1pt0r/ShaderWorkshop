using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomDirectionalLight : MonoBehaviour
{

	void Update ()
	{
		Shader.SetGlobalVector ("_GlobalLightDir", -transform.forward);
	}

}
