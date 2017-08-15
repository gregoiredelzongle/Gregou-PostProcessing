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
public class GreDitherEffect : MonoBehaviour {

	#region Public properties

	[Range(0,36)]
	public int iterations = 12;

	[Range(0,1)]
	public float sumTreeshold = 0.5f;

	#endregion

	private const string ditherInit = "Hidden/DitherInit";
	private const string dither = "Hidden/DitherErrorDiffusion";
	private const string ditherFinal = "Hidden/DitherFinal";

	private const float B = 232f;
	private float[] kernel = new float[] {
		1.0f / B,	4.0f / B,	7.0f / B,	4.0f / B,	1.0f / B,
		4.0f / B,	16.0f / B,	26.0f / B,	16.0f / B,  4.0f / B,
		7.0f / B,	26.0f / B,	0.0f / B,	26.0f / B,	7.0f / B,
		4.0f / B,	16.0f / B,	26.0f / B,	16.0f / B,	4.0f / B,
		1.0f / B,	4.0f / B,	7.0f / B,	4.0f / B,	1.0f / B
	};     

	private Material _initPassMat;
	private Material _mat;
	private Material _finalPassMat;

	private Texture2D noise;

	void OnEnable(){
		_initPassMat = new Material (Shader.Find(ditherInit));
		_mat = new Material (Shader.Find(dither));
		_finalPassMat = new Material (Shader.Find(ditherFinal));
		_mat.SetFloatArray("_Kernel",kernel);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		if (noise == null || noise.height != src.height || noise.width != src.width) {
			noise = Noise (src.width, src.height);
			_initPassMat.SetTexture("_Noise",noise);
		}
					
		var tmp1 = RenderTexture.GetTemporary (src.width, src.height);
		var tmp2 = RenderTexture.GetTemporary (src.width, src.height);

		// 1 - Initial pass
		Graphics.Blit (src, tmp1,_initPassMat);

		// 2 - Error diffusion passes
		_mat.SetFloat ("_SumTreeshold", sumTreeshold);
		bool curTmp = true;
		for (int t = 0; t < iterations; t++) {

			curTmp = t % 2 == 0;
			_mat.SetInt("_Px", t%3);
			_mat.SetInt("_Py", (t/3)%3);

			Graphics.Blit(curTmp?tmp1:tmp2,curTmp?tmp2:tmp1,_mat);
		}

		// 3 - Final pass
		Graphics.Blit (curTmp?tmp2:tmp1, dst,_finalPassMat);

		RenderTexture.ReleaseTemporary (tmp1);
		RenderTexture.ReleaseTemporary (tmp2);

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
