Shader "Unlit/CubeMapEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CubeMap("Cube Map",Cube) = "white"{}
        
        _NormalMap ("Normal Map", 2D) = "white" {}
        _NormalMapScale("Normal Map Scale",Vector) =(1,1,1,1)
        
        [Header(BlinPhong)]
        [Space(15)]
         _PowerValue("_PowerValue",Float) = 4 
        _PowerScale("_PowerScale",Float) = 1
        
        _LerpN("Lerp N",Range(0,1)) =0
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
            #pragma fullforwardshadows
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 tangent :TANGENT;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION; // 必须命名为pos ，因为 TRANSFER_VERTEX_TO_FRAGMENT 是这么命名的，为了正确地获取到Shadow
                float2 uv : TEXCOORD0;
                float3 tangent : TEXCOORD1;
                float3 bitangent : TEXCOORD2;
                float3 normal : TEXCOORD3;
                float3 worldPosition : TEXCOORD4;
                float3 localPosition : TEXCOORD5;
                float3 localNormal : TEXCOORD6;
                float4 vertexColor : TEXCOORD7;
                float2 uv2 : TEXCOORD8;
                float testValue:TEXCOORD9;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos           = UnityObjectToClipPos(v.vertex);
                o.uv            = v.uv;
                o.uv2           = v.uv2;
                o.normal        = UnityObjectToWorldNormal(v.normal);
                o.tangent       = UnityObjectToWorldDir(v.tangent);
                // o.bitangent  = cross(o.normal, o.tangent);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.localPosition = v.vertex.xyz;
                o.localNormal   = v.normal;
                o.vertexColor   = v.vertexColor;
                o.testValue     = v.tangent.w;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMapScale;

            float _PowerValue ,_PowerScale;

            samplerCUBE _CubeMap;
            float _LerpN;
            
            float4 frag(v2f i) : SV_Target
            {
                //Variable
                float3 T = normalize(i.tangent);
                float3 N = normalize(i.normal);
                float3 B = normalize( cross(N,T));
                // float3 B = normalize( i.bitangent);
                float3 L = normalize( UnityWorldSpaceLightDir(i.worldPosition.xyz));
                float3 V = normalize( UnityWorldSpaceViewDir(i.worldPosition.xyz));
                float3 H = normalize(V+L);
                float2 uv = i.uv;

                float4 BaseMap = tex2D(_MainTex,i.uv);
                // return BaseMap;
                
//================== Normal Map  ============================================== //
                float3 NormalMap = UnpackNormal(tex2D(_NormalMap,uv));

                // 
                NormalMap = lerp(float3(0,0,1),NormalMap,_LerpN);
                
		        //TBN矩阵:将世界坐标转到Tangent坐标
		        //TBN是正交矩阵，正交矩阵的逆等于其转置
                float3x3 TBN = float3x3(T,B,N);
                NormalMap *= _NormalMapScale;
                N = normalize( mul (NormalMap,TBN));
            
                // float4 Diffuse  = dot(N,L) ;
                //
                // float4 Specular = pow(dot(N,H),_PowerValue*128)*_PowerScale;      
                //
                // Diffuse = max(Diffuse,0);
                // Specular = max(Specular,0);
                //
                // Diffuse *= BaseMap;

                // return float4(uv,0,0); 
                // return -B.xyzz;

                // return N.xyzz;
                float3 R = reflect(-V, N);
                float4 cubemap = texCUBE(_CubeMap, lerp(-V,R,0.1)); // 可替换
                //float4 cubemap = texCUBE(_CubeMap,-V * 0.1 + N);
                
                return cubemap;
                
                // return Diffuse + Specular;
                
            }
            ENDCG
        }
    }
}
