using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Postprocess : MonoBehaviour {

	[SerializeField] private Material material;

	private void Awake() {
		if (material == null) {
			this.enabled = false;
		}
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination) {
		Graphics.Blit(source, destination, material);
	}

}
