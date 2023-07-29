Shader "Unlit/BasicShader_Learning" //Unlit是目录 BasicShader是命名
{
    Properties//暴露在材质面板中的属性
    {
        _MainTex ("Texture贴图2333", 2D) = "white" {} //贴图参数
        _NoiseTex ("_NoiseTex", 2D) = "white" {} //贴图参数
        _BurningValue ("_BurningValue",Float) = 1 //float 参数
        _BurningWidth ("_BurningWidth",Float) = 0.1 //float 参数
    	_BurningNoiseUVScale("_BurningNoiseUVScale",Float) = 50
    	_BurningOffset("_BurningOffset",Float) = 0.55
        [HDR]_Color ("_Color",Color) = (1,1,1,0) //颜色参数
    }

    SubShader//SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        } //Tags属性

        Pass
        {
            CGPROGRAM
            #pragma vertex vert             //定义 顶点着色器 的函数名
            #pragma fragment frag           //定义 片元(像素)着色器 的函数名

            #include "UnityCG.cginc"        //头文件

            struct MeshData //定义结构体，CPU传给GPU的的数据
            {
                //语义semantic (标记数据)
                float4 vertex : POSITION; //顶点的局部坐标
                float2 uv : TEXCOORD0; //顶点的UV
                float2 uv2 : TEXCOORD1; //顶点的UV2
                float4 normal : NORMAL; //顶点的法线
                float4 tangent: TANGENT; //顶点的切线
                float4 color : COLOR; //顶点颜色
            };

            struct VertexToFragmentData //定义结构体，在GPU中 顶点着色器 传给 片元(像素)着色器 的数据
            {
                float4 vertex : SV_POSITION; //顶点的裁剪坐标系下坐标,GPU需要改数据自己进行裁剪
                float2 uv : TEXCOORD0; //顶点的UV
                float4 worldNormal : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
                float3 localPosition : TEXCOORD3;
            };

            //数据变量
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float _BurningValue, _BurningWidth,_BurningNoiseUVScale,_BurningOffset;
            float4 _Color;

            //定义顶点着色器的函数名,与上面的 "#pragma vertex vert"相对应 
            VertexToFragmentData vert(MeshData v)
            {
                VertexToFragmentData o;
                // o.vertex = UnityObjectToClipPos(v.vertex);      //函数UnityObjectToClipPos来自"UnityCG.cginc"头文件中 //等价于mul(UNITY_MATRIX_MVP,v.vertex)
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, unity_WorldToObject);
                o.uv = v.uv;
                o.localPosition = v.vertex.xyz;
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			

            //定义片元(像素)着色器的函数名,与上面的 "#pragma fragment frag"相对应 
            float4 frag(VertexToFragmentData input) : SV_Target
            {
                //采样贴图
                float4 final = tex2D(_MainTex, input.uv);
                // float Noise = tex2D(_NoiseTex, input.uv).r;
                float Noise = SimpleNoise(input.uv*_BurningNoiseUVScale);
            	// return Noise;
                Noise += 0.1;

                float height = input.localPosition.y + _BurningOffset;
                // return input.localPosition.y;
                // return input.worldPosition.y;

                float burn = _BurningValue * Noise;

                float s1 = step(height, burn);
                float s2 = step(height, burn + _BurningWidth);
                float colorRange = s2 - s1;

                clip(height - burn);

                return lerp(final, final * _Color, colorRange);
            }
            ENDCG
        }
    }
}