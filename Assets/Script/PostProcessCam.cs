using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessCam : MonoBehaviour
{

    [SerializeField] private Material material;

    private void Start()
    {
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }


}
