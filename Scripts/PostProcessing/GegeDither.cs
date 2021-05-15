using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(GegeDitherRenderer), PostProcessEvent.AfterStack, "Gege/Dither")]
public sealed class GegeDither : PostProcessEffectSettings
{

    [Range(1, 36), Tooltip("Dither iterations")]
    public IntParameter iterations = new IntParameter { value = 12 };
    [Range(0, 1), Tooltip("Dither bias")]
    public FloatParameter sumBias = new FloatParameter { value = 0.5f };
    [Tooltip("Color Dither")]
    public ColorParameter ditherColor = new ColorParameter { value = Color.black };
    [Range(0, 1), Tooltip("Color Foreground Blend")]
    public FloatParameter colorBlend = new FloatParameter { value = 0f };
    [Tooltip("Color Background")]
    public ColorParameter backgroundColor = new ColorParameter { value = Color.white };
    [Range(0, 1), Tooltip("Color Background Blend")]
    public FloatParameter backgroundColorBlend = new FloatParameter { value = 1f };
}
public sealed class GegeDitherRenderer : PostProcessEffectRenderer<GegeDither>
{
    public override DepthTextureMode GetCameraFlags()
    {
        return DepthTextureMode.DepthNormals;
    }

    public override void Render(PostProcessRenderContext context)
    {
        
        var cmd = context.command;
        cmd.BeginSample("Dither");
        
        // Set properties
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Gege/Dither"));
        sheet.properties.SetFloat("_SumTreeshold", settings.sumBias);
        sheet.properties.SetFloat("_ColorBlend", settings.colorBlend);
        sheet.properties.SetColor("_DitherColor", settings.ditherColor);
        sheet.properties.SetFloat("_BackgroundColorBlend", settings.backgroundColorBlend);
        sheet.properties.SetColor("_BackgroundColor", settings.backgroundColor);
        cmd.SetGlobalTexture(Shader.PropertyToID("_InitTex"), context.source);

        // Initialisation
        int rt1 = Shader.PropertyToID("_Dither_Init");
        context.GetScreenSpaceTemporaryRT(cmd, rt1, 0, context.sourceFormat, RenderTextureReadWrite.Default, FilterMode.Bilinear);
        cmd.BlitFullscreenTriangle(context.source, rt1, sheet, 0);

        // Diffusion Error
        int cur = rt1;
        for (int i = 0; i < settings.iterations.value; i++)
        {
            int next = Shader.PropertyToID("_Dither_" + i);
            context.GetScreenSpaceTemporaryRT(cmd,next , 0, context.sourceFormat, RenderTextureReadWrite.Default, FilterMode.Bilinear);

            sheet.properties.SetInt("_Px", i % 3);
            sheet.properties.SetInt("_Py", (i / 3) % 3);

            cmd.BlitFullscreenTriangle(cur, next, sheet, 1);
            cmd.ReleaseTemporaryRT(cur);
            cur = next;
        }

        // Final Pass
        cmd.BlitFullscreenTriangle(cur, context.destination, sheet, 2);
        cmd.ReleaseTemporaryRT(cur);
        cmd.EndSample("Dither");
    }
}