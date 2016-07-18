using UnityEngine;
using System.Collections;

public class AutoTurn : MonoBehaviour {

	public Vector3 dir = Vector3.right;
	public float speed = 1;

	void Update()
	{
		transform.Rotate (dir * Time.deltaTime * 360 * speed);
	}
}
