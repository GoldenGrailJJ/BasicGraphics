// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BasicShader" //Unlit是目录 BasicShader是命名
{
    Properties//暴露在材质面板中的属性
    {
        _MainTex ("Texture贴图2333", 2D) = "white" {}   //贴图参数
        _Value ("_Value",Float) = 1             //float 参数
        _Color ("_Color",Color) = (1,1,1,0)      //颜色参数
    }

    SubShader//SubShader
    {
        Tags { "RenderType"="Opaque" }      //Tags属性

        Pass
        {
            CGPROGRAM
                #pragma vertex vert             //定义 顶点着色器 的函数名
                #pragma fragment frag           //定义 片元(像素)着色器 的函数名
                
                #include "UnityCG.cginc"        //头文件

                struct MeshData                  //定义结构体，CPU传给GPU的的数据
                {                   //语义semantic (标记数据)
                    float4 vertex : POSITION;       //顶点的局部坐标
                    float2 uv     : TEXCOORD0;          //顶点的UV
                    float2 uv2    : TEXCOORD1;          //顶点的UV2
                    float4 normal : NORMAL;          //顶点的法线
                    float4 tangent: TANGENT;          //顶点的切线
                    float4 color  : COLOR;             //顶点颜色
                };
                
                struct VertexToFragmentData                      //定义结构体，在GPU中 顶点着色器 传给 片元(像素)着色器 的数据
                {
                    float4 vertex : SV_POSITION;    //顶点的裁剪坐标系下坐标,GPU需要改数据自己进行裁剪
                    float2 uv : TEXCOORD0;           //顶点的UV
                    float4 worldNormal : TEXCOORD1;
                };

                //数据变量
                sampler2D _MainTex;float4 _MainTex_ST;
                float _Value;
                float4 _Color;

                //定义顶点着色器的函数名,与上面的 "#pragma vertex vert"相对应 
                VertexToFragmentData vert (MeshData v)
                {
                    VertexToFragmentData o;
                    // o.vertex = UnityObjectToClipPos(v.vertex);      //函数UnityObjectToClipPos来自"UnityCG.cginc"头文件中 //等价于mul(UNITY_MATRIX_MVP,v.vertex)
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = mul(v.normal,unity_WorldToObject);
                    o.uv = v.uv;
                    return o;
                }

                struct Data
                {
                    float a;
                    float2 b;
                    float3 c;
                    float4 d;
                };

                #define thq 1
                //定义片元(像素)着色器的函数名,与上面的 "#pragma fragment frag"相对应 
                float4 frag (VertexToFragmentData input) : SV_Target
                {
                    //采样贴图

                    // Data data = (Data)0;
                    // data.d = float(1,1,0,0);
                    // return data.d;
                    // float value1 = 12;
                    // float value2 = -100;
                    // return saturate(value1);
                    clip(0.5 - input.uv.y);

                    return thq;
                    float4 final = tex2D(_MainTex, input.uv);
                    return final;
                }
                
            ENDCG
        }
    }
}
