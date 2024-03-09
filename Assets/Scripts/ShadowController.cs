using UnityEngine;
using UnityEngine.Video;

public class ShadowController : MonoBehaviour
{
    [SerializeField] private Renderer m_shadowRenderer = default;

    [SerializeField] private VideoClip m_mainClip = default;

    private Material m_shadowMaterial = default;

    void Start()
    {
        m_shadowMaterial = m_shadowRenderer.material;

        var videoPlayer = GetComponent<VideoPlayer>();
        videoPlayer.Stop();
        videoPlayer.renderMode = VideoRenderMode.APIOnly;
        videoPlayer.prepareCompleted += Prepared;
        videoPlayer.sendFrameReadyEvents = true;
        videoPlayer.frameReady += FrameReady;
        videoPlayer.Prepare();
    }

    void Prepared(VideoPlayer vp) => vp.Pause();

    void FrameReady(VideoPlayer vp, long frameIndex)
    {
        var textureToCopy = vp.texture;
        m_shadowMaterial.SetTexture("_OverlayTex", vp.texture);

        // Perform texture copy here ...
        vp.frame = frameIndex +1;
    }
}
