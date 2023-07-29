Shader "TA/PostFX03_RadiusBlur"
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
        LOD 100

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
                float2 dir =   uv - float2(0.5,0.5);
                
                float4 RadiusBlurColor = 0;
                int SampleCount = 8;
                for(int i=0;i<SampleCount;i++)
                {
                    float2 uvRadius = uv+dir*i*0.01*_BlurIntensity;
                    RadiusBlurColor += tex2D(_MainTex,uvRadius);
                }
                
                RadiusBlurColor /= SampleCount;

                float4 FinalColor = lerp(RadiusBlurColor,SceneColor,_BlurFade);
                
                return FinalColor;
            }
            ENDCG
        }
    }
}
