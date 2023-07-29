Shader "TA/PostFX/Outline"
{
    //show values to edit in inspector
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _NormalMult ("Normal Outline Multiplier", Range(0,4)) = 1
        _NormalBias ("Normal Outline Bias", Range(1,4)) = 1
        _DepthMult ("Depth Outline Multiplier", Range(0,4)) = 1
        _DepthBias ("Depth Outline Bias", Range(1,4)) = 1
        _OutlineWidth("Outline Width",Float) =1
    }

    SubShader
    {
        // markers that specify that we don't need culling 
        // or comparing/writing to the depth buffer
        Cull off
        ZWrite off
        ZTest off

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            sampler2D _CameraDepthNormalsTexture;
            float4 _CameraDepthNormalsTexture_TexelSize;

            float4 _OutlineColor;
            float _NormalMult;
            float _NormalBias;
            float _DepthMult;
            float _DepthBias;
            float _OutlineWidth;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexToFragmentData
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            VertexToFragmentData vert(MeshData v)
            {
                VertexToFragmentData o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            ///获取 当前像素与周围像素 深度与法线的差值
            void GetDepthAndNoramlDifference(inout float depthOutline, inout float normalOutline, float baseDepth,
                                             float3 baseNormal, float2 uv, float2 offset)
            {
                //获取周围像素的 深度与法线信息
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture,uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                neighborDepth = neighborDepth * _ProjectionParams.z;

                float depthDifference = baseDepth - neighborDepth; //当前像素与周围像素 深度的差值
                depthOutline += depthDifference;

                float3 normalDifference = baseNormal - neighborNormal; //当前像素与周围像素 法线的差值
                normalDifference = normalDifference.r + normalDifference.g + normalDifference.b;
                normalOutline += normalDifference;
            }
            
            //the fragment shader
            fixed4 frag(VertexToFragmentData i) : SV_TARGET
            {
                //获取Unity 内置的 深度与法线贴图(深度与法线编码在一张图中)
                float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);

                //提取出深度与法线
                float3 normal;
                float depth;//decode 出来的Depth是 0到1 之间
                DecodeDepthNormal(depthnormal, depth, normal);

                // return depth;
                // return depthnormal.xyzz*2-1;
                
                /*
                 // x = 1 or -1 (-1 if projection is flipped)
                // y = near plane 近裁剪面
                // z = far plane  远裁剪面
                // w = 1/far plane 
                float4 _ProjectionParams;
                 */

                //get depth as distance from camera in units 
                depth = depth * _ProjectionParams.z;//0到 远裁剪面
                
                float depthDifference = 0;
                float normalDifference = 0;

                //Robert 算子
                GetDepthAndNoramlDifference(depthDifference, normalDifference, depth, normal, i.uv,
                                            _OutlineWidth * float2(1, 0));
                GetDepthAndNoramlDifference(depthDifference, normalDifference, depth, normal, i.uv,
                                            _OutlineWidth * float2(0, 1));
                GetDepthAndNoramlDifference(depthDifference, normalDifference, depth, normal, i.uv,
                                            _OutlineWidth * float2(0, -1));
                GetDepthAndNoramlDifference(depthDifference, normalDifference, depth, normal, i.uv,
                                            _OutlineWidth * float2(-1, 0));

                //深度检测值 值域控制
                depthDifference = depthDifference * _DepthMult;
                depthDifference = saturate(depthDifference);
                depthDifference = pow(depthDifference, _DepthBias);

                //法线检测值 值域控制
                normalDifference = normalDifference * _NormalMult;
                normalDifference = saturate(normalDifference);
                normalDifference = pow(normalDifference, _NormalBias);
                
                float outline = normalDifference + depthDifference;

                // return outline;
                
                float4 sourceColor = tex2D(_MainTex, i.uv);
                float4 color = lerp(sourceColor, _OutlineColor, outline);
                
                return color;
            }
            ENDCG
        }
    }
}