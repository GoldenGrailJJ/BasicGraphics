using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
public class PostFX : MonoBehaviour
{
    public enum PostFXType
    {
        Base,
        Basic,
        Transition,
        Glitch,
        Scan,
        RadiusBlur,
        Distortion,
        Impluse,
        Outline,
        AverageBlur,
        AverageBlurDownSample,
    }

    public PostFXType postFXType = PostFXType.Base;

    public Material BaseMaterial;
    public Material BasicMaterial;
    public Material TransitionMaterial;
    public Material GlitchMaterial;
    public Material ScanMaterial;
    public Material RadiusBlurMaterial;
    public Material DistortionMaterial;
    public Material ImpluseMaterial;
    public Material OutlineMaterial;
    public Material AverageBlurMaterial;

    // public float MaxScanTime = 3f;
    public float ScanSpeed = 2f;
    public float MaxScanDistance = 500f;
    public float FadeOutTime = 0.5f;

    // Start is called before the first frame update
    void Start()
    {
        //开启 深度图 法线贴图
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    public AnimationCurve ScanAnimationCurve;

    private bool IsInScan = false;

    // Update is called once per frame
    void Update()
    {
        if (postFXType == PostFXType.Scan)
        {
            // if (Input.GetKeyDown(KeyCode.P) && !IsInScan)
            if (!IsInScan)
            {
                StartCoroutine(BeginScan());
            }
        }
    }

    IEnumerator BeginScan()
    {
        Shader.SetGlobalFloat(_ScanDistanceID, 0);
        Shader.SetGlobalFloat(_ScanFadeID, 0);
        IsInScan = true;//扫描开始
        
        //传入Shader 扫描距离
        float elapse = 0;
        while (ScanSpeed * elapse < MaxScanDistance)
        {
            elapse += Time.deltaTime;
            float percent = ScanSpeed * elapse / MaxScanDistance;

            float scanDistance = ScanAnimationCurve.Evaluate(percent) * MaxScanDistance;
            Shader.SetGlobalFloat(_ScanDistanceID, scanDistance);
            // ScanMaterial.SetFloat(_ScanDistanceID, scanDistance);
            Debug.Log("_ScanDistance:" + scanDistance);
            yield return null;
        }
        
        //Fadeout 渐出
        elapse = FadeOutTime;
        while (elapse > 0)
        {
            elapse -= Time.deltaTime;
            Shader.SetGlobalFloat(_ScanFadeID, 1f - elapse / FadeOutTime);
            //ScanMaterial.SetFloat(_ScanFadeID, 1f - elapse / FadeOutTime);
            yield return null;
        }

        Shader.SetGlobalFloat(_ScanFadeID, 0);
        Shader.SetGlobalFloat(_ScanDistanceID, 0);
        IsInScan = false;//扫描结束
    }

    private static int _ScanDistanceID = Shader.PropertyToID("_ScanDistance");
    private static int _ScanFadeID = Shader.PropertyToID("_ScanFade");
    private static int _BlurTexID = Shader.PropertyToID("_BlurTex");
    private static int _SourceTexID = Shader.PropertyToID("_SourceTex");
    
    /// <summary>
    /// Unity内置的后处理函数，配合  Graphics.Blit(src, dest, mat,0); 使用
    /// </summary>
    /// <param name="src"></param>
    /// <param name="dest"></param>
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        switch (postFXType)
        {
            case PostFXType.Base:
                OnBase(src, dest);
                break;
            case PostFXType.Basic:
                OnBase(src, dest,BasicMaterial);
                break;
            case PostFXType.Transition:
                OnBase(src, dest,TransitionMaterial);
                break;
            case PostFXType.Glitch:
                OnGlitch(src, dest);
                break;
            case PostFXType.Scan:
                OnScan(src, dest);
                break;
            case PostFXType.RadiusBlur:
                OnRadiusBlur(src, dest);
                break;
            case PostFXType.Distortion:
                OnBase(src, dest, DistortionMaterial);
                break;
            case PostFXType.Impluse:
                OnBase(src, dest, ImpluseMaterial);
                break;
            case PostFXType.Outline:
                OnBase(src, dest, OutlineMaterial);
                break;
            case PostFXType.AverageBlur:
                OnBase(src, dest, AverageBlurMaterial);
                break;
            case PostFXType.AverageBlurDownSample:
                OnBlur(src, dest);
                break;

            default: break;
        }
    }

    void OnBase(RenderTexture src, RenderTexture dest)
    {
        if (BaseMaterial != null)
            Graphics.Blit(src, dest, BaseMaterial,0);
    }

    void OnBase(RenderTexture src, RenderTexture dest, Material mat)
    {
        if (mat != null)
            Graphics.Blit(src, dest, mat,0);
    }

    void OnRadiusBlur(RenderTexture src, RenderTexture dest)
    {
        if (RadiusBlurMaterial != null)
            Graphics.Blit(src, dest, RadiusBlurMaterial);
    }

    void OnGlitch(RenderTexture src, RenderTexture dest)
    {
        if (GlitchMaterial != null)
            Graphics.Blit(src, dest, GlitchMaterial);
    }

    void OnScan(RenderTexture src, RenderTexture dest)
    {
        if (ScanMaterial != null)
            Graphics.Blit(src, dest, ScanMaterial);
    }
        
    /// <summary>
    /// 降分辨率 Blur
    /// </summary>
    /// <param name="src"></param>
    /// <param name="dest"></param>
    void OnBlur(RenderTexture src, RenderTexture dest)
    {
        int width = src.width;
        int height = src.height;
        width /= 2;
        height /= 2;
        RenderTextureFormat format = src.format;
        RenderTexture rt1 = RenderTexture.GetTemporary(width, height, 0, format);
        width /= 3;
        height /= 3;
        RenderTexture rt2 = RenderTexture.GetTemporary(width, height, 0, format);
        
        Shader.SetGlobalTexture(_SourceTexID,src);
        Graphics.Blit(src, rt1,AverageBlurMaterial,1);//Dwonsample 到 1/2 的RT上
        
        Shader.SetGlobalTexture(_SourceTexID,rt1);
        Graphics.Blit(rt1, rt2,AverageBlurMaterial,1);//Dwonsample 到 1/6 的RT上
        
        Shader.SetGlobalTexture(_BlurTexID,rt2);
        Graphics.Blit(rt2, dest,AverageBlurMaterial,2);//Upsample 到目标RT上
        
        RenderTexture.ReleaseTemporary(rt1);
        RenderTexture.ReleaseTemporary(rt2);
    }
    
}