using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// [ExecuteInEditorMode]
[ExecuteInEditMode]
public class ToneMapping : MonoBehaviour
{
    Material material;
    // Start is called before the first frame update
    void Start()
    {
        var shader = Shader.Find("Ulit/ToneMapping");
        material = new Material(shader);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        Graphics.Blit(src,dest,material);
    }

}
