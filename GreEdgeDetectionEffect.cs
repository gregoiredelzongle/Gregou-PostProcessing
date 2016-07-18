//
// Kino/Motion - Motion blur effect
//
// Copyright (C) 2016 Keijiro Takahashi
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

[RequireComponent(typeof(Camera)), ExecuteInEditMode]
public class GreEdgeDetectionEffect : MonoBehaviour {


    #region Private properties

	// Material with edge detection shader stored inside
    private Material _m_edgeDetection;

	// Edge detection shader
    [SerializeField,HideInInspector]
    Shader _edgeDetectionShader;

	// normal coloring shader used as a replacment shader
    [SerializeField,HideInInspector]
    Shader _normalColoringShader;

	// Camera component accessor
	[HideInInspector]
	Camera Cam
	{
		get{
			if (_cam == null) {
				_cam = GetComponent<Camera> ();
				_cam.depthTextureMode |= DepthTextureMode.Depth;
			}
			return _cam;
		}
	}
	[SerializeField,HideInInspector]
	Camera _cam;

	// Hidden rendering camera (child of current gameobject)
	[SerializeField,HideInInspector]
	Camera _normalRenderingCam;

    #endregion

    #region Exposed properties
    public Color lineColor = Color.black;
    public Color bgColor = Color.white;

    [Range(0,1)]
    public float colorThreeshold = 0.05f;
    [Range(0, 1)]
    public float depthTreeshold = 1f;

	//public enum EdgeDetectionProperties {Source, Normals, DepthTexture, Dither, Final }
	//public EdgeDetectionProperties edgeDetectionDebug = EdgeDetectionProperties.Final;

    #endregion

	#region Main Methods

	void OnEnable()
	{
		if (_normalRenderingCam == null)
			RecreateRenderingCamera ();
	}

	void OnDestroy()
	{
		GameObject.DestroyImmediate(_normalRenderingCam.gameObject);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{

		// Display source renderTexture if selected
		/*if (edgeDetectionDebug == EdgeDetectionProperties.Source) {
			Graphics.Blit (src, dst);
			return;
		}*/
		// Check if image effects materials exists and recreate it if needed
		CheckMaterial();

		// Update shader internal properties based on exposed properties
		UpdateProperties ();

		// Create temp renderTexture
		var out_buffer = RenderTexture.GetTemporary (src.width, src.height,24,RenderTextureFormat.ARGB32);

		// Create source texture using normals color shader
		var in_buffer = GetCameraRenderTextureWithShader (_normalRenderingCam,_normalColoringShader);

		_m_edgeDetection.SetTexture ("_SourceTex", src);

		Graphics.Blit (in_buffer, dst, _m_edgeDetection);

		//Release textures;
		RenderTexture.ReleaseTemporary (in_buffer);
		RenderTexture.ReleaseTemporary (out_buffer);

	}

	#endregion

	#region Utilities Methods
	void UpdateProperties()
	{
		_m_edgeDetection.SetColor("_Color", lineColor);
		_m_edgeDetection.SetColor("_BgColor", bgColor);
		_m_edgeDetection.SetFloat("_ColorThreeshold", colorThreeshold);
		_m_edgeDetection.SetFloat("_DepthThreeshold", depthTreeshold);
	}



	void RecreateRenderingCamera()
	{
		Transform camTransform = transform.Find ("GreEdgeDetectionRenderingCamera");
		if (camTransform == null) {
			camTransform = new GameObject ("GreEdgeDetectionRenderingCamera").transform;
			_normalRenderingCam = camTransform.gameObject.AddComponent<Camera> ();
			camTransform.SetParent (transform, false);
		} else {
			_normalRenderingCam = camTransform.gameObject.GetComponent<Camera>();
		}
		_normalRenderingCam.CopyFrom (Cam);
		_normalRenderingCam.enabled = false;
		_normalRenderingCam.gameObject.hideFlags = HideFlags.HideAndDontSave;

	}

	void CheckMaterial()
	{
		if (_m_edgeDetection == null)
		{
			_m_edgeDetection = new Material(_edgeDetectionShader);
			_m_edgeDetection.hideFlags = HideFlags.DontSave;
		}
	}

	RenderTexture GetCameraRenderTexture(Camera cam)
	{
		var temp = cam.targetTexture = RenderTexture.GetTemporary(cam.pixelWidth, cam.pixelHeight,24,RenderTextureFormat.ARGB32);
		cam.targetTexture.Create ();
		cam.Render ();
		cam.targetTexture = null;
		return temp;
	}

	RenderTexture GetCameraRenderTextureWithShader(Camera cam,Shader shader)
	{
		var temp = cam.targetTexture = RenderTexture.GetTemporary(cam.pixelWidth, cam.pixelHeight,24,RenderTextureFormat.ARGB32);
		cam.targetTexture.Create ();
		cam.RenderWithShader (shader,"");
		cam.targetTexture = null;
		return temp;
	}
	#endregion
}
