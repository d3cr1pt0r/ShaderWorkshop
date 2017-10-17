using UnityEngine;
using System.Collections;

public class CubeMapGenerator : MonoBehaviour
{
    /*
	 * Creates a cubemap from a camera and feeds it to a material
	 */


    public Camera sourceCamera;
    public int cubeMapRes = 128;

    public RenderTexture renderTex;

    public void Update()
    {
        GenerateCubeMap();
    }

    public RenderTexture GenerateCubeMap() {
        if (renderTex == null) {
            renderTex = new RenderTexture(cubeMapRes, cubeMapRes, 16);
            renderTex.dimension = UnityEngine.Rendering.TextureDimension.Cube;
            renderTex.hideFlags = HideFlags.HideAndDontSave;
            renderTex.useMipMap = true;
            renderTex.autoGenerateMips = true;
        }

        sourceCamera.RenderToCubemap(renderTex);

        Shader.SetGlobalTexture("_CubeMap", renderTex);

        return renderTex;
    }


}