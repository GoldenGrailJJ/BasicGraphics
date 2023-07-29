Shader "Unlit/LightingModel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value ("_Value",Float) =1
        _RangeValue("_RangeValue",Range(0,1)) = 0.5
        _Color ("_Color",Color) = (0.5,0.3,0.2,1)
        
        _PhongExp("_PhongExp",Float) =1
        _PhongScale("_PhongScale",Float) =1
        
        _BlinPhongExp("_BlinPhongExp",Float) =1
        _BlinPhongScale("_BlinPhongScale",Float) =1
        _WrapValue("_WrapValue",Float) =1
        
        [Space(5)]
        _CheapSSSValue("_CheapSSSValue",Float) = 0.5
        _CheapSSSExp("_CheapSSSExp",Float) = 1
        _CheapSSSScale("_CheapSSSScale",Float) = 1
        
        [Space(10)]
        _GouraudExp("_GouraudExp",Float) = 1
        _GouraudScale("_GouraudScale",Float) =1
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue" = "Geometry"
        }
        //"LightMode"="ForwardBase" ForwardBase 让Shader接受主光源影响

        /*
        //Transparent Setup
         Tags { "Queue"="Transparent"  "RenderType"="Transparent" "LightMode"="ForwardBase"}
         Blend SrcAlpha OneMinusSrcAlpha
        */

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fullforwardshadows
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityGlobalIllumination.cginc"
            #include "AutoLight.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex       : POSITION;
                float2 uv           : TEXCOORD0;
                float2 uv2          : TEXCOORD1;
                float4 tangent      : TANGENT;
                float3 normal       : NORMAL;
                float4 vertexColor  : COLOR;
            };

            struct Vertex2FragmentData
            {
                float4 pos              : SV_POSITION; // 必须命名为pos ，因为 TRANSFER_VERTEX_TO_FRAGMENT 是这么命名的，为了正确地获取到Shadow
                float2 uv               : TEXCOORD0;
                float3 tangent          : TEXCOORD1;
                float3 bitangent        : TEXCOORD2;
                float3 normal           : TEXCOORD3;
                float3 worldPosition    : TEXCOORD4;
                float3 localPosition    : TEXCOORD5;
                float3 localNormal      : TEXCOORD6;
                float4 vertexColor      : TEXCOORD7;
                float2 uv2              : TEXCOORD8;
                float4 gouraud          : TEXCOORD9;
                // LIGHTING_COORDS(9, 10)
            };

            float _GouraudExp ,_GouraudScale; // 10 参数
            Vertex2FragmentData vert(MeshData v)
            {
                Vertex2FragmentData o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.localPosition = v.vertex.xyz;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                o.localNormal = v.normal;
                o.vertexColor = v.vertexColor;

                //Gouraud Lighting
                float3 N = normalize(o.normal);                                     //世界空间 法线
                float3 L = normalize(UnityWorldSpaceLightDir(o.worldPosition.xyz)); //世界空间 光线
                float3 V = normalize(UnityWorldSpaceViewDir(o.worldPosition.xyz));  //世界空间 视角
                float3 R = reflect(-L,N);                                           //世界空间 反射光线
                float VR = dot(V,R);
                float Gouraud = pow(VR, _GouraudExp)*_GouraudScale; // 10 高洛德

                o.gouraud = Gouraud;
                
                // TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _PhongExp,_PhongScale;
            float _BlinPhongExp,_BlinPhongScale;
            float _WrapValue;
            float _CheapSSSValue,_CheapSSSExp,_CheapSSSScale;

            // float4 frag(Vertex2FragmentData i) : SV_Target
            // {
            //     return i.gouraud;
                
            //     float3 N = normalize(i.normal);                                     //世界空间 法线
            //     float3 L = normalize(UnityWorldSpaceLightDir(i.worldPosition.xyz)); //世界空间 光线
            //     float3 V = normalize(UnityWorldSpaceViewDir(i.worldPosition.xyz));  //世界空间 视角
            //     float3 R = reflect(-L,N);                                           //世界空间 反射光线
            //     float3 H = normalize(L+V);                                          //世界空间 半角向量
            //     float NL = dot(N,L);

            //     // return floor( (NL*0.5+0.5)* 2)/2;
                
            //     float4 FinalColor =0;
            //     float4 Diffuse  =0;
            //     float4 Specular =0;
                
            //     float Lambert = NL;
            //     float HalfLambert = pow( NL*0.5+0.5 ,2);

            //     float DiffuseWrap = pow(dot(N,L)*_WrapValue+(1-_WrapValue),2);
            //     // return DiffuseWrap;

            //     float VR = dot(V,R);
            //     float Phong = pow(VR, _PhongExp)*_PhongScale;
                
            //     float NH = dot(N,H);
            //     float BlinPhong = pow(NH,_BlinPhongExp)*_BlinPhongScale;
                
            //     Diffuse = max( 0,HalfLambert);
            //     Specular =max(0, BlinPhong);

            //     // return Diffuse + Specular;
                
            //     float4 BaseColor = tex2D(_MainTex,i.uv2);

            //     float3 N_Shift = -normalize(N*_CheapSSSValue+L);//沿着光线方向上偏移法线，最后在取反
            //     float BackLight = (pow(saturate( dot(N_Shift,V)) ,_CheapSSSExp)*_CheapSSSScale);

            //     FinalColor = (Diffuse+BackLight) *BaseColor + Specular;
                
            //     return FinalColor;
            // }

            float4 frag(Vertex2FragmentData i) : SV_Target
            {
                return i.gouraud;
                
                float3 N = normalize(i.normal);                                     //世界空间 法线
                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPosition.xyz)); //世界空间 光线
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPosition.xyz));  //世界空间 视角
                float3 R = reflect(-L,N);                                           //世界空间 反射光线
                float3 H = normalize(L+V);                                          //世界空间 半角向量
                float NL = dot(N,L);

                
                float4 FinalColor =0;
                float4 Diffuse  =0;
                float4 Specular =0;
                
                float Lambert = NL;
                //return Lambert; // 1

                float HalfLambert = pow( NL * 0.5 + 0.5 , 2 );

                // return HalfLambert; // 2

                // return step(0.5, HalfLambert); // 3 二分明暗
                

                // return floor( (NL * 0.5 + 0.5) * 5 ) / 5; // 4 多分明暗

                float VR = dot(V,R);
                float Phong = pow(VR, _PhongExp)*_PhongScale;

                // return Phong; // 5

                float NH = dot(N,H);
                float BlinPhong = pow(NH,_BlinPhongExp)*_BlinPhongScale;

                // return BlinPhong; // 6

                Diffuse = max(0, HalfLambert);
                Specular = max(0, BlinPhong);
                
                // return Diffuse + Specular; // 7 漫反射 + 高光

                
                float4 BaseColor = tex2D(_MainTex,i.uv2);
                float3 N_Shift = -normalize(N*_CheapSSSValue+L);//沿着光线方向上偏移法线，最后在取反
                float BackLight = (pow(saturate( dot(N_Shift,V)) ,_CheapSSSExp)*_CheapSSSScale);
                
                // return BackLight; // 8 背光
                // return Diffuse + Specular + BackLight; // 9 漫反射 + 高光
                // return (Diffuse + BackLight) * BaseColor  + Specular ; // 9 漫反射 + 高光



                float DiffuseWrap = pow(dot(N,L)*_WrapValue+(1-_WrapValue),2);
                // return DiffuseWrap; // 完整光照

                // FinalColor = (Diffuse+BackLight) *BaseColor + Specular;
                
                // //return FinalColor;
            }
            ENDCG
        }
    }
}
