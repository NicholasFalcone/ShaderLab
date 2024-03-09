using UnityEngine.Rendering.Universal;

[System.Serializable]
public class CustomPostProcessRenderer : ScriptableRendererFeature
{
    CustomPostProcessPass m_RenderPass = null;
 
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RenderPass);
    }
 
    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        base.SetupRenderPasses(renderer, renderingData);
        m_RenderPass.SetTarget(renderer.cameraColorTargetHandle);
    }
 
    public override void Create()
    {
        m_RenderPass = new CustomPostProcessPass();
    }
 
    protected override void Dispose(bool disposing)
    {
        ///...
    }
}