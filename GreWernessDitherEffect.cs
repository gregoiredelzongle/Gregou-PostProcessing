//
// Gre/Sketch - Dithering and Edge Detection effect
// Inspired and based on Lucas Pope technical devlog : https://forums.tigsource.com/?topic=40832.0
// Werness algorithm by Brent Werness
//
// Copyright (C) 2016 Gregoire Delzongle
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

using UnityEngine;

[RequireComponent(typeof(Camera)),ExecuteInEditMode]
public class GreWernessDitherEffect : MonoBehaviour {

	#region Public properties
	public Shader ditheringShader;
	public Shader initPassDitheringShader;
	public Shader finalPassDitheringShader;

	public enum DitherEffectStep{Source,Noise,InitialPass,Dithering,Final}
	public DitherEffectStep step = DitherEffectStep.Final;

	[Range(0,36)]
	public int Iterations = 12;

	[Range(0,1)]
	public float sumTreeshold = 0.5f;

	[Range(0,1)]
	public float depthTreeshold = 1f;


	#endregion

	#region Accessors
	Camera Cam
	{
		get {
			if (_cam == null)
				_cam = GetComponent<Camera> ();
			return _cam;
		}
	}
	Camera _cam;

	Material Mat
	{
		get{
			if (_mat == null) {
				_mat = new Material (ditheringShader);
				_mat.hideFlags = HideFlags.DontSave;
				}
			return _mat;
		}
	}
	Material _mat;

	Material FinalPassMat
	{
		get{
			if (_finalPassMat == null) {
				_finalPassMat = new Material (finalPassDitheringShader);
				_finalPassMat.hideFlags = HideFlags.DontSave;
			}
			return _finalPassMat;
		}
	}
	Material _finalPassMat;

	Material InitPassMat
	{
		get{
			if (_initPassMat == null) {
				_initPassMat = new Material (initPassDitheringShader);
				_initPassMat.hideFlags = HideFlags.DontSave;
			}
			return _initPassMat;
		}
	}
	Material _initPassMat;

	Texture2D noise;

	#endregion


	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		if (step == DitherEffectStep.Source) {
			Graphics.Blit (src, dst);
			return;
		}

		if (noise == null || noise.height != src.height || noise.width != src.width)
			noise = Noise (src.width, src.height);
		var rt = RenderTexture.GetTemporary (src.width, src.height);



		InitPassMat.SetTexture("_Noise",noise);

		Graphics.Blit (src, rt,InitPassMat);

		InitPassMat.DisableKeyword ("SHOW_NOISE");


		if (step == DitherEffectStep.Noise) {
			InitPassMat.EnableKeyword ("SHOW_NOISE");
			Graphics.Blit (rt, dst);
			RenderTexture.ReleaseTemporary (rt);
			return;
		}

		if (step == DitherEffectStep.InitialPass) {
			Graphics.Blit (rt, dst);
			RenderTexture.ReleaseTemporary (rt);
			return;
		}


		Mat.SetFloat ("_SumTreeshold", sumTreeshold);

		for (int t = 0; t < Iterations; t++) {
			
			Mat.SetInt("_Px", t%3);
			Mat.SetInt("_Py", (t/3)%3);

			var rt2 = RenderTexture.GetTemporary (rt.width, rt.height);
			Graphics.Blit(rt,rt2,Mat);
			RenderTexture.ReleaseTemporary (rt);
			rt = rt2;
		}

		Graphics.Blit (rt, dst,FinalPassMat);
		RenderTexture.ReleaseTemporary (rt);

	}

	Texture2D Noise(int width, int height)
	{
		Texture2D noise = new Texture2D (width, height);
		for (int i = 0; i < width; i++) {
			for (int j = 0; j < height; j++) {
				noise.SetPixel(i,j,new Color(0f, Random.value,Random.value));
			}
		}
		noise.Apply ();
		return noise;
	}
}
