Shader "MagicTavern/PhysicallyBasedShading/DisneyPrincipledBRDFShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Specular("Specular", Range(0,1)) = 0.5
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal",2D) = "bump"{}//此处必须填写bump，否则在没有法线贴图的情况下，会出错
        _Roughness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _SpecularTint("SpeculatTint",Range(0,1)) =0.5
        _Sheen("_Sheen",Range(0,1)) = 0
        _SheenTint("SheenTint",Range(0,1)) = 0.5
        _ClearcoatGloss("ClearcoatGloss",Range(0,1)) = 1
        _Clearcoat("Clearcoat",Range(0,1)) = 1
        _Subsurface("Subsurface",Range(0,1)) = 0.5
        _Anisotropic("Anisotropic",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            half _Roughness;
            half _Metallic;
            fixed4 _Color;
            float _Specular;
            float _SpecularTint;
            float _Sheen;
            float _SheenTint;
            float _ClearcoatGloss;
            float _Clearcoat;
            float _Subsurface;
            float _Anisotropic;
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 tangent : TEXCOORD3;
            };
            float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) 
            {
                return cross(normal, tangent.xyz) *
                    (binormalSign * unity_WorldTransformParams.w);
            }
            void InitializeFragmentNormal(inout v2f i) 
            {
                float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);                
                i.normal = normalize(
                    tangentSpaceNormal.x * i.tangent +
                    tangentSpaceNormal.y * binormal +
                    tangentSpaceNormal.z * i.normal
                );
            }
            
            //法线分布函数D
            //其基本形式是：c/pow((a^2*cos(NdotH)^2 + sin(NdotH)^2),b)
            //其中c为放缩常数，a为粗糙度
            //当b=1时，为Trowbridge-Reitz公式。
            //当b=2时，为Berry公式。
            //Disney的BRDF使用两个specular lobe:
            //b=2为主波瓣，用来表达基础材质。
            //b=1为次级波瓣，用来表达清漆层。
            float GTR1(float NdotH, float a)//用于清漆表面
            {
                if (a >= 1) return 1/UNITY_PI;
                float a2 = a*a;
                float t = 1 + (a2-1)*NdotH*NdotH;
                return (a2-1) / (UNITY_PI*log(a2)*t);
            }
            float GTR2(float NdotH, float a)//用于各项同性的表面
            {
                float a2 = pow(a,2);
                float t = 1 + (a2-1)*pow(NdotH,2);                
                return a2 / (UNITY_PI * pow(t,2));
            }
            float GTR2_aniso(float NdotH, float HdotX, float HdotY, float ax, float ay)//用于各项异性的表面
            {
                return 1 / (UNITY_PI * ax*ay * pow(pow(HdotX/ax,2) + pow(HdotY/ay,2) + NdotH*NdotH,2));
            }
            
            //菲涅尔项F
            float SchlickFresnel(float u)
            {
                float m = clamp(1-u, 0, 1);
                return pow(m,5);
            }
            
            //几何遮蔽项G
            //主波瓣各向同性
            //参考Walter的近似方法，使用Smith GGX导出的G项，
            //将粗糙度参数进行重映射以减少光泽表面的极端增益，即将α 从[0, 1]重映射到[0.5, 1]
            float smithG_GGX(float NdotV, float alphaG)//用于各项同性的表面
            {
                float a = alphaG*alphaG;
                float b = NdotV*NdotV;
                return 1 / (NdotV + sqrt(a + b - a*b));
            }
            //主波瓣各项异性
            float smithG_GGX_aniso(float NdotV, float VdotX, float VdotY, float ax, float ay)//用于各项异性的表面
            {
                return 1 / (NdotV + sqrt( pow(VdotX*ax,2) + pow(VdotY*ay,2) + pow(NdotV,2) ));
            }
            //次级波，只有各向同性
            //对于对清漆层进行处理的次级波瓣，Disney没有使用Smith G推导，而是直接使用固定粗糙度为0.25的GGX的G项
            //float G_GGX(float NdotV, float alphag)
            //{
            //    float a = alphag * alphag;
            //    float b = NdotV * NdotV;
            //    return 1.0 / (NdotV + sqrt(a + b - a * b));
            //}
            //漫反射项
            float DisneyFresnel(float NdotL,float NdotV,float LdotH,float roughness)
            {
                float FL = SchlickFresnel(NdotL);
                float FV = SchlickFresnel(NdotV);
                float Fd90 = 0.5 + 2 * LdotH*LdotH * roughness;
                float Fd = lerp(1.0, Fd90, FL) * lerp(1.0, Fd90, FV);//这个结果需要乘以baseColor/PI
                return Fd;
            }    
            
            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
                return o;
            }
            float4 frag (v2f i) : SV_Target
            {
                InitializeFragmentNormal(i);               
                float4 albedo = tex2D (_MainTex, i.uv);
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 X = (1,1,1);
                float3 Y = (1,1,1);
                float NdotL = saturate(dot(N,L));
                float NdotV = saturate(dot(N,V));

                float3 H = normalize(L+V);
                float NdotH = saturate(dot(N,H));
                float LdotH = saturate(dot(L,H));
                float roughness = _Roughness;
                float metallic = _Metallic;
                //省去gammar空间到Linear空间的变换
                float Cdlum = Luminance(albedo);
                float3 Ctint = Cdlum > 0 ? _Color/Cdlum : float3(1,1,1);
                float3 Cspec0 = lerp(_Specular*0.08*lerp(float3(1,1,1), Ctint, _SpecularTint), albedo, metallic);
                float3 Csheen = lerp(float3(1,1,1),Ctint,_SheenTint);
                
                // Diffuse fresnel - go from 1 at normal incidence to .5 at grazing
                // and mix in diffuse retro-reflection based on roughness
                float FL = SchlickFresnel(NdotL);
                float FV = SchlickFresnel(NdotV);
                float Fd90 = 0.5 + 2 * LdotH*LdotH * roughness;
                float Fd = lerp(1.0, Fd90, FL) * lerp(1.0, Fd90, FV);//这个结果需要乘以baseColor/PI
                
                float Fss90 = LdotH * LdotH * roughness;
                float Fss = lerp(1,Fss90,FL) * lerp(1,Fss90,FV);
                float ss = 1.25 * (Fss * (1 / (NdotL + NdotV) - 0.5) + 0.5);
                // specular
                float aspect = sqrt(1-_Anisotropic*0.9);
                float ax = max(0.001,pow(roughness,2) / aspect);
                float ay = max(0.001,pow(roughness,2) * aspect);
                float Ds = GTR2_aniso(NdotH,dot(H,X),dot(H,Y),ax,ay);
                float FH = SchlickFresnel(LdotH);
                float3 Fs = lerp(Cspec0, float3(1,1,1), FH);
                float Gs;
                Gs  = smithG_GGX_aniso(NdotL, dot(L, X), dot(L, Y), ax, ay);
                Gs *= smithG_GGX_aniso(NdotV, dot(V, X), dot(V, Y), ax, ay);
                
                // sheen
                float3 Fsheen = FH * _Sheen * Csheen;
                
                // clearcoat (ior = 1.5 -> F0 = 0.04)
                float Dr = GTR1(NdotH, lerp(0.1,0.001,_ClearcoatGloss));
                float Fr = lerp(0.04, 1.0, FH);
                float Gr = smithG_GGX(NdotL, 0.25) * smithG_GGX(NdotV, 0.25);
                
                return float4((UNITY_INV_PI * lerp(Fd, ss, _Subsurface)*albedo + Fsheen) * 
                       (1-metallic) + Gs*Fs*Ds + 0.25 * _Clearcoat*Gr*Fr*Dr,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
