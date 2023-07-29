Shader "TA/PostFX_AverageBlur"
{
    Properties
    {
//        _MainTex ("Texture", 2D) = "white" {}
        _BlurIntensity("BlurIntensity",Float) = 1
        _BlurFade("BlurFade",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        //Pass 0
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;//贴图 一个像素的大小，1/With 1/Height

            float _BlurFade,_BlurIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 SceneColor = tex2D(_MainTex, i.uv);
                float2 uv = i.uv;
                float4 BlurColor = 0;
                
                float Width = 2; //  (-2,0)  (-1,0) (0,0) (1,0) (2,0)
                for (float dx=-Width;dx<=Width;dx++)
                {
                    for (float dy=-Width;dy<=Width;dy++)
                    {
                        float2 uvOffset = uv + float2(dx,dy)*_MainTex_TexelSize.xy*_BlurIntensity;
                        BlurColor += tex2D(_MainTex,uvOffset);
                    }
                }
                float total = (Width*2+1)*(Width*2+1);
                BlurColor = BlurColor / total;
                return  lerp ( BlurColor,SceneColor,_BlurFade);

            }
            ENDCG
        }
        
        //Pass 1
        //Down sample
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _SourceTex;
            // float4 _MainTex_ST;
            float4 _SourceTex_TexelSize;//贴图 一个像素的大小，1/With 1/Height

            float _BlurFade,_BlurIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 SceneColor = tex2D(_SourceTex, i.uv);
                // return SceneColor.r;
                float2 uv = i.uv;
                //
                float4 BlurColor = 0;
                int SampleCount = 9;

                float Width = 2;
                for (float dx=-Width;dx<=Width;dx++)
                {
                    for (float dy=-Width;dy<=Width;dy++)
                    {
                        float2 uvOffset = uv + float2(dx,dy)*_SourceTex_TexelSize.xy*_BlurIntensity;
                        BlurColor += tex2D(_SourceTex,uvOffset);
                    }
                }
                float total = (Width*2+1)*(Width*2+1);
                BlurColor = BlurColor / total;
                return BlurColor;
                
            }
            ENDCG
        }
        
        //Pass 2
        //Up sample
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _BlurTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;//贴图 一个像素的大小，1/With 1/Height
            
            float _BlurFade,_BlurIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 SceneColor = tex2D(_MainTex, i.uv);
                float4 BlurColor = tex2D(_BlurTex, i.uv);
                return  lerp ( BlurColor,SceneColor,_BlurFade);
                // return SceneColor.r;
            }
            ENDCG
        }
    }
}
