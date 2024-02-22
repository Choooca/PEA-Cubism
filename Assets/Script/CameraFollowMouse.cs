using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollowMouse : MonoBehaviour
{
    private Vector2 previousMousePos;

    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        transform.rotation *= Quaternion.AngleAxis(Input.GetAxis("Mouse X"), Vector3.up);
        transform.rotation *= Quaternion.AngleAxis(Input.GetAxis("Mouse Y"), Vector3.left);
        transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y, 0);
    }
}
