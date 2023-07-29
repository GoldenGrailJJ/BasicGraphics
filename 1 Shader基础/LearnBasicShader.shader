Shader "Unlit/VerySao/LearnBasicShader"
{
    Properties//属性
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value("这是一个实数",Float) = 1
        _Color("这是一个颜色",Color) =(1,1,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  //函数UnityObjectToClipPos来自"UnityCG.cginc"头文件中 //等价于mul(UNITY_MATRIX_MVP,v.vertex)
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
        
    }
}
