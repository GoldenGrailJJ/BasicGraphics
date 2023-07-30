Shader "TA102/PBR_Tex"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        // _BRDFLUTTex ("_BRDFLUTTex", 2D) = "white" {}
        // _RangeValue("_RangeValue",Range(0,1)) = 0.5
        // _Color ("_Color",Color) = (0.5,0.3,0.2,1)
        // _BaseColor ("_BaseColor",Color) = (0.5,0.3,0.2,1)
        [Toggle]_RevertUV("Revert UV",Float)  = 0
        _BaseMap ("BaseMap", 2D) = "white" {}
        _RoughnessMap ("Roughness", 2D) = "white" {}
        _MetallicMap ("Metallic", 2D) = "White" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _EmissionMap ("Emission", 2D) = "black" {}
        _ShadowIntensity("Shadow Intensity",Range(0,1)) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
    }
    SubShader
    {
        Tags {  "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue" = "Geometry"}
        
        Pass
        {
            Cull [_Cull]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma fullforwardshadows
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" 
            // #define UNITY_SPECCUBE_LOD_STEPS
            #include "UnityStandardConfig.cginc"
            #include "AutoLight.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent :TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 tangent      : TEXCOORD1;
                float3 normal       : TEXCOORD2; 
                float3 worldPosition : TEXCOORD3;
                float3 localPostion  : TEXCOORD4;
                LIGHTING_COORDS(9, 10)
            };

            sampler2D _BaseMap,_RoughnessMap,_MetallicMap,_NormalMap,_EmissionMap;
            sampler2D _BRDFLUTTex;
            float _RevertUV;
            float _ShadowIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                o.localPostion = v.vertex.xyz;
                o.tangent = UnityObjectToWorldNormal(v.tangent) ;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            #define PI 3.141592654

            //D
            float D_DistributionGGX(float3 N,float3 H,float Roughness)
            {
                float a             = Roughness*Roughness;
                float a2            = a*a;
                float NH            = saturate(dot(N,H));
                float NH2           = NH*NH;
                float nominator     = a2;
                float denominator   = (NH2*(a2-1.0)+1.0);
                denominator         = PI * denominator*denominator;
                
                return              nominator/ max(denominator,0.001) ;//防止分母为0
            }

            // Anisotropic GGX
            // [Burley 2012, "Physically-Based Shading at Disney"]
            float D_DistributionGGXAnisotropic( float RoughnessX, float RoughnessY, float NoH, float3 H, float3 X, float3 Y )
            {
                float ax = RoughnessX * RoughnessX;
                float ay = RoughnessY * RoughnessY;
                float XoH = dot( X, H );
                float YoH = dot( Y, H );
                float d = XoH*XoH / (ax*ax) + YoH*YoH / (ay*ay) + NoH*NoH;
                return 1 / ( PI * ax*ay * d*d );
            }

            //G
            float GeometrySchlickGGX(float NV,float Roughness)
            {
                float r = Roughness +1.0;
                float k = r*r / 8.0;
                float nominator = NV;
                float denominator = k + (1.0-k) * NV;
                return nominator/ max(denominator,0.001) ;//防止分母为0
            }

            // float GeometrySchlickGGX(float NV, float k)
            // {
            //     float nominator   = NV;
            //     float denominator = NV * (1.0 - k) + k;
                
            //     return nominator/ max(denominator,0.001) ;
            // }

            float G_GeometrySmith(float3 N,float3 V,float3 L,float Roughness)
            {
                float NV = saturate(dot(N,V));
                float NL = saturate(dot(N,L));

                float ggx1 = GeometrySchlickGGX(NV,Roughness);
                float ggx2 = GeometrySchlickGGX(NL,Roughness);

                return ggx1*ggx2;

            }

            //F
            float3 F_FrenelSchlick(float NV,float3 F0)
            {
                return F0 +(1 - F0)*pow(1-NV,5);
            }

            float3 FresnelSchlickRoughness(float NV,float3 F0,float Roughness)
            {
                return F0 + (max(float3(1.0 - Roughness, 1.0 - Roughness, 1.0 - Roughness), F0) - F0) * pow(1.0 - NV, 5.0);
            }

            //UE4 Black Ops II modify version
            float2 EnvBRDFApprox(float Roughness, float NV )
            {
                // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
                // Adaptation to fit our G term.
                const float4 c0 = { -1, -0.0275, -0.572, 0.022 };
                const float4 c1 = { 1, 0.0425, 1.04, -0.04 };
                float4 r = Roughness * c0 + c1;
                float a004 = min( r.x * r.x, exp2( -9.28 * NV ) ) * r.x + r.y;
                float2 AB = float2( -1.04, 1.04 ) * a004 + r.zw;
                return AB;
            }

            // Black Ops II
            // float2 EnvBRDFApprox(float Roughness, float NV)
            // {
            //     float g = 1 -Roughness;
            //     float4 t = float4(1/0.96, 0.475, (0.0275 - 0.25*0.04)/0.96, 0.25);
            //     t *= float4(g, g, g, g);
            //     t += float4(0, 0, (0.015 - 0.75*0.04)/0.96, 0.75);
            //     float A = t.x * min(t.y, exp2(-9.28 * NV)) + t.z;
            //     float B = t.w;
            //     return float2 ( t.w-A,A);
            // }如果

            float3 ACESToneMapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x*(a*x+b))/(x*(c*x+d)+e));
            }
            float4 ACESToneMapping(float4 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x*(a*x+b))/(x*(c*x+d)+e));
            }
            
            float4 frag (v2f i,float face : VFACE ) : SV_Target
            {
                //Variable
                float3 T = normalize(i.tangent);
                float3 N = normalize(i.normal);
                float3 B = normalize(cross(N,T));
                
                float3 L = normalize( UnityWorldSpaceLightDir(i.worldPosition.xyz));
                float3 V = normalize( UnityWorldSpaceViewDir(i.worldPosition.xyz));
                float3 H = normalize(V+L);
                float2 uv = lerp(i.uv,float2(i.uv.x,1-i.uv.y),_RevertUV);

//================== Normal Map  ============================================== //
                float3 NormalMap = UnpackNormal(tex2D(_NormalMap,uv));
                
                float3x3 TBN = float3x3(T,B,N);
                N = normalize( mul (NormalMap,TBN)); //正交矩阵的逆矩阵等于转置矩阵
                
//================== PBR  ============================================== //
            // sampler2D _BaseMap,_RoughnessMap,_MetallicMap,_NormalMap,_EmissionMap;

                // float3 BaseColor = float3(0.5,0.3,0.2);
                float3 BaseColor = tex2D(_BaseMap,uv);
                float Roughness = tex2D(_RoughnessMap,uv);
                float Metallic =  tex2D(_MetallicMap,uv);
                float3 F0 = lerp(0.04,BaseColor,Metallic);
                float3 Radiance = _LightColor0.xyz;

//================== Direct Light  ============================================== //
                //Specular
                //Cook-Torrance BRDF
                float HV = saturate(dot(H,V));
                float NV = saturate(dot(N,V));
                float NL = saturate(dot(N,L));
               
                float D = D_DistributionGGX(N,H,Roughness);
                float3 F = F_FrenelSchlick(NV,F0);
                float G = G_GeometrySmith(N,V,L,Roughness);

                float3 KS = F;
                float3 KD = 1-KS;
                KD*=1-Metallic;
                float3 nominator = D*F*G;
                float denominator = max(4*NV*NL,0.001);
                float3 Specular = nominator/denominator;
                
                
                //Diffuse
                // float3 Diffuse = KD * BaseColor / PI;
                float3 Diffuse = KD * BaseColor ;

                float3 DirectLight = (Diffuse + Specular)*NL *Radiance;
                // float3 DirectLight = G;
                // return D;
                // return G;

//================== Indirect Light  ============================================== //
                float3 IndirectLight = 0;

                //Specular
                float3 R = reflect(-V,N);
                float3 F_IndirectLight = FresnelSchlickRoughness(NV,F0,Roughness);
                // float3 F_IndirectLight = F_FrenelSchlick(NV,F0);
                float mip = Roughness*(1.7 - 0.7*Roughness) * UNITY_SPECCUBE_LOD_STEPS ;
                float4 rgb_mip = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,R,mip);

                //间接光镜面反射采样的预过滤环境贴图
                float3 EnvSpecularPrefilted = DecodeHDR(rgb_mip, unity_SpecCube0_HDR);
                
                // return EnvSpecularPrefilted.xyzz;
                //LUT采样
                // float2 env_brdf = tex2D(_BRDFLUTTex, float2(NV, Roughness)).rg; //0.356
                // float2 env_brdf = tex2D(_BRDFLUTTex, float2(lerp(0, 0.99, NV), lerp(0, 0.99, Roughness))).rg;

                //数值近似
                float2 env_brdf = EnvBRDFApprox(Roughness,NV);

                float3 Specular_Indirect = EnvSpecularPrefilted  * (F_IndirectLight * env_brdf.r + env_brdf.g);

                // return (F_IndirectLight * env_brdf.r + env_brdf.g).xyzz;

                //Diffuse           
                float3 KD_IndirectLight = 1 - F_IndirectLight;
                KD_IndirectLight *= 1 - Metallic;
                
                float3 irradianceSH = ShadeSH9(float4(N,1));
                // return irradianceSH.rgbb;
                // float3 Diffuse_Indirect = irradianceSH * BaseColor / PI *KD_IndirectLight;
                float3 Diffuse_Indirect = irradianceSH * BaseColor  *KD_IndirectLight ;
                
                // float3 EnvCubeMap = texCUBE(_EnvCubeMap,N).xyz;
                // return ACESToneMapping(EnvCubeMap.xyzz*3);

                IndirectLight = Diffuse_Indirect + Specular_Indirect;

                // return Diffuse_Indirect.xyzz;
                // return  ShadeSH9(float4(N,1)).xyzz;

                float shadow = SHADOW_ATTENUATION(i);
                shadow = lerp(1,shadow,_ShadowIntensity);

                float4 FinalColor =0;
                FinalColor.rgb = DirectLight*shadow + IndirectLight;
                //HDR => LDR aka ToneMapping
                // return G;
                // FinalColor.rgb = ACESToneMapping(FinalColor.rgb);

                //Linear => Gamma
                // FinalColor = pow(FinalColor,1/2.2);
                
                return min(FinalColor,100.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
