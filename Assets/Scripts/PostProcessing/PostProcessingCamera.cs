using UnityEngine;

public class PostProcessingCamera : MonoBehaviour
{
    [SerializeField] private Material postMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        postMaterial.SetTexture("_MainTex", destination);
        Graphics.Blit(source, destination, postMaterial);
    }

}
