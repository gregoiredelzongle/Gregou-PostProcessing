using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace Gregou.PostProcessing
{
    [Serializable]
    [PostProcess(typeof(GregouEdgeDetectionRenderer), PostProcessEvent.AfterStack, "Gregou/EdgeDetection")]
    public sealed class GregouEdgeDetection : PostProcessEffectSettings
    {
        [Tooltip("Color for the outline")]
        public ColorParameter outlineColor = new ColorParameter { value = Color.black };
        [Tooltip("Color for the background")]
        public ColorParameter backgroundColor = new ColorParameter { value = Color.clear };
        [Range(0f, 1f), Tooltip("Bias between two differents colors")]
        public FloatParameter colorBias = new FloatParameter { value = 0.2f };
        [Range(0f, 1f), Tooltip("Depth limit for the shader")]
        public FloatParameter depthBias = new FloatParameter { value = 1.0f };
        [Range(1f, 5f), Tooltip("Outline Width")]
        public FloatParameter outlineWidth = new FloatParameter { value = 1.0f };

    }
    public sealed class GregouEdgeDetectionRenderer : PostProcessEffectRenderer<GregouEdgeDetection>
    {
        public override DepthTextureMode GetCameraFlags()
        {
            return DepthTextureMode.DepthNormals;
        }

        public override void Render(PostProcessRenderContext context)
        {
            context.command.BeginSample("Edge Detection");

            // Set properties
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Gregou/EdgeDetection"));
            sheet.properties.SetColor("_OutlineColor", settings.outlineColor);
            sheet.properties.SetColor("_BackgroundColor", settings.backgroundColor);
            sheet.properties.SetFloat("_ColorBias", settings.colorBias);
            sheet.properties.SetFloat("_DepthBias", settings.depthBias);
            sheet.properties.SetFloat("_OutlineWidth", settings.outlineWidth);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
            context.command.EndSample("Edge Detection");

        }
    } 
}