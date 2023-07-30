Shader "Unlit/MyPBR"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _BRDFLUTTex ("_BRDFLUTTex", 2D) = "white" {}
        // _Value ("_Value",Float) =1
        // _RangeValue("_RangeValue",Range(0,1)) = 0.5
        // _Color ("_Color",Color) = (0.5,0.3,0.2,1)
        _BaseColor ("_BaseColor",Color) = (0.5,0.3,0.2,1)

//        _Roughness("_Roughness",Range(0,1)) = 0.5
//        [Gamma]_Metallic("_Metallic",Range(0,1)) = 0.5

//        _EnvCubeMap("_EnvCubeMap",CUBE) = ""
        
        [Space]
        [Space]
        [Space]

        _BaseColorTex ("_BaseColorTex", 2D) = "white" {}
        _MetallicTex ("_MetallicTex", 2D) = "white" {}
        _RoughnessTex ("_RoughnessTex", 2D) = "white" {}
        
        _EmissionTex ("_EmissionTex", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)
        _NormalTex ("_NormalTex", 2D) = "black" {}
        _AOTex ("_AOTex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}//LightMode 设置为ForwardBase，否则ShadeSH9()会出错。

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityGlobalIllumination.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent :TANGENT;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 tangent      : TEXCOORD1;
                float3 bitangent    : TEXCOORD2; 
                float3 normal       : TEXCOORD3; 
                float3 worldPosition: TEXCOORD4;
                float3 localPostion : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float  _Value,_RangeValue;
            float4 _Color,_BaseColor;

            float _Metallic,_Roughness;
            sampler2D _BRDFLUTTex;

            // samplerCUBE _EnvCubeMap;

            sampler2D _BaseColorTex,_MetallicTex,_RoughnessTex;
            sampler2D _EmissionTex,_AOTex,_NormalTex;
            float4 _EmissionColor;
         
            #define PI 3.14159265358979323846

            //D
            float D_DistributionGGX(float3 N,float3 H,float Roughness)
            {
                // 将粗糙度值 Roughness 平方，并赋值给变量 a
                float a = Roughness * Roughness;
                // a 是粗糙度的平方，用于后续计算

                // 将 a 平方，并赋值给变量 a2
                float a2 = a * a;
                // a2 是粗糙度的平方的平方，用于后续计算

                // 计算法线向量 N 和半角向量 H 的点乘结果 NH，并取其与0的最大值
                // NH 表示法线向量 N 和半角向量 H 的夹角余弦值
                float NH = max(dot(N, H), 0);

                // 将 NH 平方，并赋值给变量 NH2
                float NH2 = NH * NH;
                // NH2 是法线向量 N 和半角向量 H 的夹角余弦值的平方，用于后续计算

                // 计算 Cook-Torrance BRDF 中的分子 nominator
                // nominator = a2
                float nominator = a2;
                // nominator 表示 Cook-Torrance BRDF 中的分子部分，这里为 a 的平方


                // 计算 Cook-Torrance BRDF 中的分母 denominator
                // denominator = NH2 * (a2 - 1.0) + 1.0
                float denominator = NH2 * (a2 - 1.0) + 1.0;
                // denominator 表示 Cook-Torrance BRDF 中的分母部分，这里是 NH2 * (a2 - 1.0) + 1.0 的计算结果

                // 将 denominator 平方，并乘以 PI，再将结果再平方，并赋值给 denominator
                // denominator = PI * denominator * denominator
                denominator = PI * denominator * denominator;
                // denominator 表示 Cook-Torrance BRDF 中的分母部分，这里是对原分母的两次平方，再乘以 PI 的结果
                
                return              nominator/ max(denominator,0.0000001) ;//防止分母为0
                // return              nominator/ (denominator) ;//防止分母为0
            }
            //G
            float GeometrySchlickGGX(float NV,float Roughness)
            {
                // 计算一个新的 roughness 值 r，为 Roughness + 1.0
                float r = Roughness + 1.0;
                // r 表示经过偏移的 roughness 值，用于后续计算

                // 计算常数值 k，为 r 平方的 1/8
                float k = r * r / 8.0;
                // k 是用于后续计算的常数值，为 r 平方的 1/8

                // 计算分子 nominator，为视角向量 V 和法线向量 N 的点乘结果 NV
                float nominator = NV;
                // nominator 表示视角向量 V 和法线向量 N 的夹角余弦值 NV，用于后续计算

                // 计算分母 denominator，为 k 与 (1.0 - k) * NV 之和
                float denominator = k + (1.0 - k) * NV;
                // denominator 表示 Cook-Torrance BRDF 中的分母部分，这里是 k 和 (1.0 - k) * NV 之和

                // 防止分母为0的情况，使用 max 函数将分母的值与一个极小值 0.0000001 进行比较取最大值
                // 这是为了避免分母为0导致除法运算的错误
                return nominator / max(denominator, 0.0000001);
                // 返回计算得到的 Cook-Torrance BRDF 中的结果
                // 这里使用了 max 函数来确保分母不会为0，防止除法错误

            }

            float G_GeometrySmith(float3 N,float3 V,float3 L,float Roughness)
            {
                float NV = max(dot(N,V),0);
                float NL = max(dot(N,L),0);

                float ggx1 = GeometrySchlickGGX(NV,Roughness);
                float ggx2 = GeometrySchlickGGX(NL,Roughness);

                return ggx1*ggx2;

            }
            
            //F
            float3 F_FrenelSchlick(float NV,float3 F0)
            {
                return F0 +(1.0 - F0)*pow(1.0-NV,5);
            }

            float3 FresnelSchlickRoughness(float NV,float3 F0,float Roughness)
            {
                float smoothness = 1.0 - Roughness;
                return F0 + (max(smoothness.xxx, F0) - F0) * pow(1.0 - NV, 5.0);
            }
            
            //UE4 Black Ops II modify version
            float2 EnvBRDFApprox(float Roughness, float NoV )
            {
                // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
                // Adaptation to fit our G term.
                const float4 c0 = { -1, -0.0275, -0.572, 0.022 };
                const float4 c1 = { 1, 0.0425, 1.04, -0.04 };
                float4 r = Roughness * c0 + c1;//mad:multiply add
                float a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;//mad
                float2 AB = float2( -1.04, 1.04 ) * a004 + r.zw;//mad
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
            // }
            
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

            // 定义一个结构体 v2f，用于传递顶点数据到片段着色器
            v2f vert (appdata v)
            {
                // // 创建一个 v2f 类型的实例 o，用于存储顶点着色器的输出数据
                // v2f o;
                
                // // 物体的坐标和法线 --> 世界空间下的坐标和法线
                // // 1 将顶点位置转换为裁剪空间，并存储到 v2f 实例 o 的 vertex 变量中
                // o.vertex = UnityObjectToClipPos(v.vertex);

                // // 2 将顶点的纹理坐标存储到 v2f 实例 o 的 uv 变量中
                // o.uv = v.uv;

                // // 3 将顶点的法线向量从局部空间转换为世界空间，并存储到 v2f 实例 o 的 normal 变量中
                // o.normal = UnityObjectToWorldNormal(v.normal);

                // // 
                // // 4 将顶点的世界空间位置计算，并存储到 v2f 实例 o 的 worldPosition 变量中
                // // 通过乘以 unity_ObjectToWorld 矩阵将局部坐标转换为世界坐标
                // o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                // // 5 将顶点的局部空间位置存储到 v2f 实例 o 的 localPostion 变量中
                // // 注意：由于 v2f 的 vertex 变量在顶点着色器中被转换为裁剪空间坐标，所以这里的 localPostion 只包含 xyz 分量
                // o.localPostion = v.vertex.xyz;

                // // 6 将顶点的切线向量从局部空间转换为世界空间，并存储到 v2f 实例 o 的 tangent 变量中
                // o.tangent = UnityObjectToWorldNormal(v.tangent);

                // // 注释掉下面的代码，暂时不使用，后续可能在片段着色器中使用
                // // o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                // // 返回顶点着色器的输出 v2f 实例 o
                // return o;


            
                v2f o; // 创建一个 v2f 类型的实例 o，用于存储顶点着色器的输出数据

                // 1 将顶点的局部空间位置存储到 v2f 实例 o 的 localPostion 变量中
                // 注意：由于 v2f 的 vertex 变量在顶点着色器中被转换为裁剪空间坐标，所以这里的 localPostion 只包含 xyz 分量
                o.localPostion = v.vertex.xyz;

                // 2 将顶点的法线向量从局部空间转换为世界空间，并存储到 v2f 实例 o 的 normal 变量中
                o.normal = UnityObjectToWorldNormal(v.normal);

                // 3 将顶点的切线向量从局部空间转换为世界空间，并存储到 v2f 实例 o 的 tangent 变量中
                o.tangent = UnityObjectToWorldNormal(v.tangent);

                // 4 将顶点的纹理坐标存储到 v2f 实例 o 的 uv 变量中
                o.uv = v.uv;

                // 5 将顶点的世界空间位置计算，并存储到 v2f 实例 o 的 worldPosition 变量中
                // 通过乘以 unity_ObjectToWorld 矩阵将局部坐标转换为世界坐标
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                // 6 将顶点位置转换为裁剪空间，并存储到 v2f 实例 o 的 vertex 变量中
                o.vertex = UnityObjectToClipPos(v.vertex);

                // 注释掉下面的代码，暂时不使用，后续可能在片段着色器中使用
                // o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                // 返回顶点着色器的输出 v2f 实例 o
                return o;

            }

            float3 Specluar_Cook_Torrance(float3 L,float3 V,float3 N,float Roughness,float3 F0)
            {
                // 根据金属度值在BaseColor和0.04之间进行插值，得到F0值
                // float3 F0 = lerp(0.04, BaseColor, Metallic);
                // 在这里注释掉上面的插值代码，直接设置F0为一个固定值
                // 这里使用了0.04作为F0的默认值，表示非金属材质的反射率
                //float3 F0 = 0.04;

                // 计算半角向量 H，即视线方向向量 V 和光照方向向量 L 的标准化平均向量
                // 这个向量用于计算镜面高光
                float3 H = normalize(V + L);

                // 计算视角向量 V 和半角向量 H 的点乘结果 HV，并取其与0的最大值
                // HV表示视角向量 V 和半角向量 H 的夹角余弦值
                float HV = max(dot(H, V), 0);

                // 计算法线向量 N 和视角向量 V 的点乘结果 NV，并取其与0的最大值
                // NV表示法线向量 N 和视角向量 V 的夹角余弦值
                float NV = max(dot(N, V), 0);

                // 计算法线向量 N 和光照方向向量 L 的点乘结果 NL，并取其与0的最大值
                // NL表示法线向量 N 和光照方向向量 L 的夹角余弦值
                float NL = max(dot(N, L), 0);

                // 使用 Distribution GGX 函数计算粗糙度值 Roughness 下的分布函数 D
                // D_DistributionGGX 函数用于计算 Distribution GGX 函数，其输入包括法线向量 N、半角向量 H 和粗糙度 Roughness
                float D = D_DistributionGGX(N, H, Roughness);

                // 使用 Schlick's approximation 近似计算 Fresnel 反射率
                // F_FrenelSchlick 函数用于计算 Schlick's approximation 近似的 Fresnel 反射率
                // 其输入为法线向量 N 和视角向量 V，以及一个常数值 1
                float3 F = F_FrenelSchlick(NV, 1);

                // 使用 Geometry Smith 函数计算几何遮挡项 G
                // G_GeometrySmith 函数用于计算 Geometry Smith 函数，其输入包括法线向量 N、视角向量 V、光照方向向量 L 和粗糙度 Roughness
                float G = G_GeometrySmith(N, V, L, Roughness);

                // 计算 specular 颜色值
                // 将 Distribution、Fresnel 反射率和几何遮挡项相乘，并除以 4*NV*NL 和一个极小值 0.001
                // 得到 specular 颜色值，用于表示材质的镜面高光
                float3 nominator = D * F * G;
                float denominator = max(4 * NV * NL, 0.001);
                float3 Specular = nominator / denominator;

                // 返回计算得到的 Specular 颜色值
                return Specular;

            }

            float4 frag (v2f i) : SV_Target
            {
                // 变量定义
                float3 T = normalize(i.tangent); // 计算切线向量，并将其标准化，确保长度为1
                float3 N = normalize(i.normal); // 计算法线向量，并将其标准化，确保长度为1
                float3 B = normalize(cross(N, T)); // 计算副切线向量，通过叉乘法与法线向量和切线向量正交，并将其标准化，确保长度为1
                
                
                // float3 B = normalize(i.bitangent); // 注释掉上面的计算方式，使用预计算的副切线向量
                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPosition.xyz)); // 计算世界空间中的光照方向向量，并将其标准化，确保长度为1
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPosition.xyz)); // 计算世界空间中的视线方向向量，并将其标准化，确保长度为1
                float3 H = normalize(V + L); // 计算半程向量（视线向量与光照方向向量之和），并将其标准化，确保长度为1，用于计算镜面反射
                float2 uv = i.uv; // 获取顶点的纹理坐标，用于采样纹理进行着色


//================== Normal Map  ============================================== //
                // 从法线贴图中解包得到法线向量
                float3 NormalMap = UnpackNormal(tex2D(_NormalTex, uv));
                // UnpackNormal 函数用于从法线贴图中解包法线向量，_NormalTex 是法线贴图的采样器，uv 是当前顶点的纹理坐标

                // 构建 TBN 矩阵
                float3x3 TBN = float3x3(T, B, N);
                // T、B、N 分别为切线、副切线和法线向量，构成了 TBN 矩阵
                // TBN 矩阵用于将法线贴图中的法线向量从切线空间转换为世界空间或视图空间

                // 将法线向量从切线空间转换为世界空间或视图空间
                N = normalize(mul(NormalMap, TBN));
                // 通过将法线向量与 TBN 矩阵相乘，将法线从切线空间转换为世界空间或视图空间
                // 最后再对结果进行标准化，确保法线向量的长度为1

                // 注：这里的 TBN 矩阵是一个正交矩阵，所以它的逆矩阵等于其转置矩阵
                // 在法线贴图中存储的法线向量通常是在切线空间中，这里使用 TBN 矩阵将其转换到世界空间或视图空间
                // 这样在片段着色器中就可以基于顶点的法线信息进行光照计算和表面细节处理

                // N.x = dot(float3(T.x,B.x,N.x),NormalMap);
                // N.y = dot(float3(T.y,B.y,N.y),NormalMap);
                // N.z = dot(float3(T.z,B.z,N.z),NormalMap);

//================== PBR  ============================================== //

                // 从_BaseColorTex纹理中采样得到基础颜色
                float3 BaseColor = tex2D(_BaseColorTex, uv);

                // _BaseColorTex是基础颜色贴图的采样器，uv是当前顶点的纹理坐标
                // BaseColor是一个三维向量，包含基础颜色的RGB分量

                // 不要加入高光，注释掉下面的代码，保持BaseColor不受高光影响
                // return BaseColor.xyzz;

                // 从_RoughnessTex纹理中采样得到粗糙度值
                float Roughness = tex2D(_RoughnessTex, uv).r;
                // _RoughnessTex是粗糙度贴图的采样器，uv是当前顶点的纹理坐标
                // Roughness是一个标量，表示材质的粗糙度，值越大漫反射越多，表面越粗糙

                // 从_MetallicTex纹理中采样得到金属度值
                float Metallic = tex2D(_MetallicTex, uv).r;
                // _MetallicTex是金属度贴图的采样器，uv是当前顶点的纹理坐标
                // Metallic是一个标量，表示材质的金属度，值越大金属度越高，材质呈现金属质感

                // 从_EmissionTex纹理中采样得到自发光值
                float3 Emission = tex2D(_EmissionTex, uv);
                // _EmissionTex是自发光贴图的采样器，uv是当前顶点的纹理坐标
                // Emission是一个三维向量，包含自发光的RGB分量，用于实现自发光效果
                //return Emission.xyyz;

                // 从_AOTex纹理中采样得到环境遮挡（Ambient Occlusion）值
                float3 AO = tex2D(_AOTex, uv);
                // _AOTex是环境遮挡贴图的采样器，uv是当前顶点的纹理坐标
                // AO是一个三维向量，用于模拟环境光遮挡效果

                // 使用lerp函数根据金属度值在BaseColor和0.04之间进行插值，得到F0值
                float3 F0 = lerp(0.04, BaseColor, Metallic);
                // F0是Fresnel反射率，用于描述非金属表面的反射特性
                // lerp函数在0.04和BaseColor之间进行插值，插值系数由Metallic决定
                // 当Metallic为0时，F0等于0.04，当Metallic为1时，F0等于BaseColor

                // 获取第一个光源的颜色，用于计算材质的辐射亮度（Radiance）
                float3 Radiance = _LightColor0.xyz;
                // _LightColor0是第一个光源的颜色，_LightColor0.xyz表示颜色的RGB分量
                // Radiance是一个三维向量，用于表示光源的颜色，用于计算材质的辐射亮度


//================== Direct Light  ============================================== //
                // Specular
                // 使用 Cook-Torrance BRDF 计算镜面高光
                // HV 表示视线方向向量 V 和光照方向向量 L 的半角向量与法线 N 的夹角余弦值
                float HV = max(dot(H, V), 0);
                // NV 表示视线方向向量 V 和法线 N 的夹角余弦值
                float NV = max(dot(N, V), 0);
                // NL 表示法线 N 和光照方向向量 L 的夹角余弦值
                float NL = max(dot(N, L), 0);

                // 使用 Cook-Torrance BRDF 计算镜面高光的颜色值
                // Specluar_Cook_Torrance 函数用于根据光照方向向量 L、视线方向向量 V、法线 N、粗糙度 Roughness 和 Fresnel 反射率 F0 计算镜面高光颜色
                float3 Specular = Specluar_Cook_Torrance(L, V, N, Roughness, F0);
                // return Specular.xyzz;

                // Diffuse
                // 计算漫反射颜色
                // 使用 Schlick's approximation 近似计算镜面反射率
                // KS 表示视角和法线的 Schlick's approximation 镜面反射率
                float3 KS = F_FrenelSchlick(HV, F0);
                // KD 表示漫反射的反射率，由基础颜色 BaseColor 和金属度 Metallic 决定
                float3 KD = (1 - KS) * (1 - Metallic);

                // 计算漫反射颜色 Diffuse
                // Diffuse = KD * BaseColor，没有除以 PI
                float3 Diffuse = KD * BaseColor;

                // 计算直接光照的颜色，包括漫反射和镜面高光部分
                // DirectLight = (Diffuse + Specular) * NL * Radiance，其中 Radiance 表示光源颜色
                //return Diffuse.xyzz;
                float3 DirectLight = (Diffuse + Specular) * NL * Radiance;
                // return DirectLight.xyzz;

    
//================== Indirect Light  ============================================== //
                float3 IndirectLight = 0;

                //Specular
                // 计算反射向量 R
                // 使用 reflect 函数，根据入射向量 V 和表面法线 N 计算出反射向量 R
                float3 R = reflect(-V, N);
                // R 表示表面的反射向量，即光线从表面反射出去的方向

                // 使用 FresnelSchlickRoughness 函数计算间接光的菲涅尔反射项 F_IndirectLight
                // FresnelSchlickRoughness 函数用于计算基于 Schlick 近似和粗糙度的菲涅尔反射项
                // F_IndirectLight 表示间接光的菲涅尔反射项，影响表面在不同视角下的镜面反射强度
                float3 F_IndirectLight = FresnelSchlickRoughness(NV, F0, Roughness);

                // 计算材质球谐光照环境贴图的LOD（级别）
                // Roughness 控制 LOD 的计算，使其在粗糙度较小时增加，较大时减小
                // mip 表示计算得到的 LOD 值，用于后续环境贴图的采样
                float mip = Roughness * (1.7 - 0.7 * Roughness) * UNITY_SPECCUBE_LOD_STEPS;
                // UNITY_SPECCUBE_LOD_STEPS 为预定义常量，表示环境贴图的LOD级别数量

                // 根据反射向量 R 和 LOD 值 mip，采样预过滤环境贴图，并将结果存储到 rgb_mip
                // 这里使用 UNITY_SAMPLE_TEXCUBE_LOD 函数进行贴图采样
                float4 rgb_mip = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip);

                // 解码采样得到的 HDR 贴图值，得到间接光的镜面反射采样结果 EnvSpecularPrefilted
                // 这里使用 DecodeHDR 函数解码采样结果，得到实际的 HDR 线性空间颜色值
                // 
                float3 EnvSpecularPrefilted = DecodeHDR(rgb_mip, unity_SpecCube0_HDR);
                //return EnvSpecularPrefilted.xyzz;

                // 从 BRDF Lookup Table (LUT) 中采样环境反射的值 env_brdf
                // 这里使用 EnvBRDFApprox 函数进行数值近似采样
                // env_brdf 表示环境反射的值，影响间接光的镜面反射强度
                float2 env_brdf = EnvBRDFApprox(Roughness, NV);

                // 计算间接光的镜面反射分量 Specular_Indirect
                // Specular_Indirect 为预过滤环境贴图与菲涅尔反射项 F_IndirectLight 和环境反射值 env_brdf 的乘积
                // 最终得到间接光的镜面反射效果
                float3 Specular_Indirect = EnvSpecularPrefilted * (F_IndirectLight * env_brdf.r + env_brdf.g);
                
                //return Specular_Indirect.xyzz;
                
                //Diffuse           
                // 计算间接光的漫反射项
                // 通过将直接光中的镜面反射项 F_IndirectLight 从 1 中减去，得到漫反射项的权重
                float3 KD_IndirectLight = float3(1, 1, 1) - F_IndirectLight;
                // KD_IndirectLight 表示间接光中漫反射项的权重，即光线被表面吸收的部分

                // 将 KD_IndirectLight 乘以 (1 - Metallic) 的值，控制金属度对漫反射的影响
                // 当 Metallic 较小时，KD_IndirectLight 将保留较大的权重，表现为较强的漫反射效果
                // 当 Metallic 较大时，KD_IndirectLight 将减小，表现为更多的光线被表面吸收，更强的镜面反射效果
                KD_IndirectLight *= 1 - Metallic;

                // 使用 ShadeSH9 函数计算光照的球谐函数值
                // ShadeSH9 函数基于光照环境计算出一个 9 个值的球谐函数系数
                // 这些系数可以用来近似计算表面在各个方向上的漫反射光照
                float3 irradianceSH = ShadeSH9(float4(N, 1));
                // irradianceSH 表示光照环境的球谐函数系数

                // 计算间接光的漫反射分量 Diffuse_Indirect
                // Diffuse_Indirect 为球谐函数值与基础颜色 BaseColor 的乘积，并乘以 KD_IndirectLight
                // 这里未除以 PI，因为在之前的计算中已经包含了 PI 的计算
                // Diffuse_Indirect 表示间接光的漫反射分量，表面在各个方向上的漫反射光照
                float3 Diffuse_Indirect = irradianceSH * BaseColor * KD_IndirectLight;
                //return Diffuse_Indirect.xyzz;

                // 计算最终的间接光照值 IndirectLight
                // IndirectLight 为漫反射分量 Diffuse_Indirect 加上镜面反射分量 Specular_Indirect，并乘以 AO
                // AO 为环境光遮蔽的值，用于衰减光照的强度
                // 最终得到的 IndirectLight 表示间接光的总光照效果
                IndirectLight = (Diffuse_Indirect + Specular_Indirect) * AO;

                
                float4 FinalColor =0;

                FinalColor.rgb = DirectLight + IndirectLight;

                FinalColor.rgb += Emission * _EmissionColor;

                //HDR => LDR aka ToneMapping
                // FinalColor.rgb = ACESToneMapping(FinalColor.rgb);
                
                //Linear => Gamma
                // FinalColor = pow(FinalColor,1/2.2);
                
                return FinalColor;
            }
            ENDCG
        }
    }
}
