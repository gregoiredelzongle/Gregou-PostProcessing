using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SinglePassDither : MonoBehaviour {

	private const string ditherShader = "Hidden/DitherSinglePass";
	Material ditherMat;

	void OnEnable(){
		ditherMat = new Material (Shader.Find (ditherShader));
		ditherMat.hideFlags = HideFlags.DontSave;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		var rt = RenderTexture.GetTemporary (src.width, src.height);

		Graphics.Blit (src, dst, ditherMat);

		RenderTexture.ReleaseTemporary (rt);

	}
}
