// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE_LightingModel"
{
	Properties
	{
		_CheapSSSShift("CheapSSSShift", Float) = 0
		_CheapSSSExp("CheapSSSExp", Float) = 1
		_CheapSSSScale("CheapSSSScale", Float) = 1
		_BlinPhongExp("BlinPhongExp", Float) = 1
		_BlinPhongScale("BlinPhongScale", Float) = 1
		_TextureSample0("Texture Sample 0", 2D) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform float _CheapSSSShift;
			uniform float _CheapSSSExp;
			uniform float _CheapSSSScale;
			uniform sampler2D _TextureSample0;
			uniform float _BlinPhongExp;
			uniform float _BlinPhongScale;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 N12 = normalizedWorldNormal;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float3 L10 = worldSpaceLightDir;
				float dotResult22 = dot( N12 , L10 );
				float HalfLambert31 = pow( ( ( dotResult22 * 0.5 ) + 0.5 ) , 2.0 );
				float3 normalizeResult89 = normalize( ( ( N12 * _CheapSSSShift ) + L10 ) );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 V11 = ase_worldViewDir;
				float dotResult78 = dot( -normalizeResult89 , V11 );
				float CheapSSS90 = ( pow( dotResult78 , _CheapSSSExp ) * _CheapSSSScale );
				float2 texCoord124 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float3 normalizeResult111 = normalize( ( L10 + V11 ) );
				float3 H112 = normalizeResult111;
				float dotResult102 = dot( N12 , H112 );
				float BlinPhong107 = ( pow( dotResult102 , _BlinPhongExp ) * _BlinPhongScale );
				
				
				finalColor = ( ( ( max( HalfLambert31 , 0.0 ) + max( CheapSSS90 , 0.0 ) ) * tex2D( _TextureSample0, texCoord124 ) ) + BlinPhong107 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
6.666667;18;1693.333;914.3334;-965.5475;-2003.681;2.614708;True;True
Node;AmplifyShaderEditor.WorldNormalVector;3;-2156.162,165.8883;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1;-2173.162,-194.1117;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-1803.684,155.3226;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;91;-487.7197,2067.366;Inherit;False;1976.127;511.2856;CheapSSS;12;88;89;76;79;81;83;78;72;70;74;73;90;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-1804.684,-193.6774;Inherit;False;L;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-403.7198,2120.699;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-396.7198,2214.366;Inherit;False;Property;_CheapSSSShift;CheapSSSShift;4;0;Create;True;0;0;0;False;0;False;0;1.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;-673.7642,114.7106;Inherit;False;1550.03;425.6546;HalfLambert;7;27;24;25;23;30;29;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-2140.162,-11.11176;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;24;-623.7642,164.7106;Inherit;False;467.5714;303.2857;[-1,1];3;20;21;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-437.7197,2396.699;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-141.7196,2117.366;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-569.7642,214.7106;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;67.15854,2173.435;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-1798.684,-16.67744;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-573.7642,352.7106;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-2417.266,727.6952;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-2409.266,881.6951;Inherit;False;11;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;22;-310.7642,231.7106;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-239.7642,360.3773;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;89;236.1584,2194.435;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-2127.764,796.1949;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;430.2805,2359.366;Inherit;False;11;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-23.76416,222.3773;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;76;484.2805,2211.366;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;27;150.2358,190.3773;Inherit;False;204.5714;183.5714;[0,1];1;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;30;217.9796,425.0795;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;200.2358,240.3773;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;78;711.2806,2221.366;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;111;-1978.764,797.195;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;81;710.2806,2341.366;Inherit;False;Property;_CheapSSSExp;CheapSSSExp;6;0;Create;True;0;0;0;False;0;False;1;12.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;705.2806,2463.366;Inherit;False;Property;_CheapSSSScale;CheapSSSScale;7;0;Create;True;0;0;0;False;0;False;1;4.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;113;9.442295,3194.51;Inherit;False;1086.548;390.2856;BlinPhong;6;103;104;102;105;101;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-1741.764,805.195;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;178;955.2803,2217.366;Inherit;False;PowerScale;-1;;22;240e17d62fabf46488b4d5d44fa65237;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;451.9796,251.0795;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;66.44234,3367.51;Inherit;False;112;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;59.44236,3244.51;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;629.9796,247.0795;Inherit;False;HalfLambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;1242.121,2168.735;Inherit;False;CheapSSS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;2289.326,3162.4;Inherit;False;90;CheapSSS;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;360.442,3469.51;Inherit;False;Property;_BlinPhongScale;BlinPhongScale;13;0;Create;True;0;0;0;False;0;False;1;13.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;102;371.4419,3277.51;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;348.442,3390.51;Inherit;False;Property;_BlinPhongExp;BlinPhongExp;11;0;Create;True;0;0;0;False;0;False;1;1339;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;2245.758,2994.118;Inherit;False;31;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;127;2545.872,3007.954;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;179;586.4421,3290.51;Inherit;False;PowerScale;-1;;21;240e17d62fabf46488b4d5d44fa65237;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;128;2551.69,3148.363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;2095.758,3378.118;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;69;-1031.144,1276.688;Inherit;False;2304.872;730.578;BandedLight;11;47;46;53;57;56;58;60;63;64;61;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;2704.757,3096.118;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;849.7047,3308.344;Inherit;False;BlinPhong;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;122;2413.758,3355.118;Inherit;True;Property;_TextureSample0;Texture Sample 0;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;120;2492.299,3578.898;Inherit;False;107;BlinPhong;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-411.2781,-256.9577;Inherit;False;1031.957;303.2857;Lambert;5;19;15;17;16;32;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;2800.757,3318.118;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;99;-109.859,2690.61;Inherit;False;1172.714;386.2856;Phong;6;97;95;94;92;98;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;-207.1436,1654.33;Inherit;False;204.5714;183.5714;[0,1];1;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-981.1438,1628.663;Inherit;False;467.5714;303.2857;[-1,1];4;51;50;49;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-638.9464,783.5127;Inherit;False;1461.843;392.9524;DiffuseWrap;10;35;37;36;39;34;40;33;38;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;39;-100.9464,1066.179;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;2960.559,2564.481;Inherit;False;Property;_Float6;Float 6;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;177;467.1407,2786.61;Inherit;False;PowerScale;-1;;23;240e17d62fabf46488b4d5d44fa65237;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;172;2769.782,2360.986;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;113.5859,1703.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-67.85895,2833.61;Inherit;False;13;R;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-588.9464,971.5127;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;1854.632,2484.328;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;64;400.442,1513.688;Inherit;False;Property;_Color1;Color 1;2;0;Create;True;0;0;0;False;0;False;0.7786889,0,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;170;2612.922,2331.31;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;4;-1987.162,421.8883;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-155.414,1891.98;Inherit;False;Property;_BandedNumber;BandedNumber;3;0;Create;True;0;0;0;False;0;False;5;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;131;1082.908,3271.552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;40;397.0536,860.1794;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-1787.597,412.6176;Inherit;False;R;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-644.1434,1815.33;Inherit;False;Constant;_Float3;Float 3;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;966.1798,2848.026;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-59.8589,2740.61;Inherit;False;11;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;576.6109,870.1575;Inherit;False;DiffuseWrap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;92;252.141,2773.61;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;2525.058,3262.941;Inherit;False;Constant;_Float4;Float 4;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-157.1436,1704.33;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;374.3935,-188.3524;Inherit;False;Lambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-584.9464,833.5127;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;174;2731.628,2544.697;Inherit;False;Property;_CheapSSSexp;CheapSSSexp;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-357.2781,-206.9577;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-361.2781,-68.95766;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-98.27831,-189.9577;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;50.72174,-196.9577;Inherit;False;NL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;50;-668.1438,1695.663;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;176;3138.616,2366.639;Inherit;False;PowerScale;-1;;20;240e17d62fabf46488b4d5d44fa65237;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;58;286.586,1693.98;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;218.0536,978.1794;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;8;-2334.682,516.0115;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;6;-2390.682,367.0115;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;169;2416.493,2286.088;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;1848.192,2212.442;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;166;1848.586,2344.144;Inherit;False;Property;_Float5;Float 5;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;690.4034,2804.444;Inherit;False;Phong;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-927.1438,1678.663;Inherit;False;12;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-381.1436,1686.33;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;33;-325.9464,850.5127;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;61;757.442,1599.688;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;2199.049,2246.637;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;97;246.141,2889.61;Inherit;False;Property;_PhongExp;PhongExp;9;0;Create;True;0;0;0;False;0;False;1;4.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;1021.886,1600.963;Inherit;False;BandedLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-90.94637,874.1794;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;60;458.5856,1715.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;2542.264,2444.363;Inherit;False;11;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;169.0536,850.1794;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;7;-2137.682,382.0115;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;98;241.141,2965.61;Inherit;False;Property;_PhongScale;PhongScale;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-931.1438,1816.663;Inherit;False;10;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;63;424.4419,1326.688;Inherit;False;Property;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;1,0,0,0;0.490566,0.490566,0.490566,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;-357.9464,1034.179;Inherit;False;Property;_WrapValue;WrapValue;0;0;Create;True;0;0;0;False;0;False;0;0.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;3135.35,3347.199;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3340.709,3371.84;Float;False;True;-1;2;ASEMaterialInspector;100;1;ASE_LightingModel;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;12;0;3;0
WireConnection;10;0;1;0
WireConnection;73;0;72;0
WireConnection;73;1;74;0
WireConnection;88;0;73;0
WireConnection;88;1;70;0
WireConnection;11;0;2;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;89;0;88;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;23;0;22;0
WireConnection;23;1;25;0
WireConnection;76;0;89;0
WireConnection;26;0;23;0
WireConnection;26;1;25;0
WireConnection;78;0;76;0
WireConnection;78;1;79;0
WireConnection;111;0;110;0
WireConnection;112;0;111;0
WireConnection;178;1;78;0
WireConnection;178;2;81;0
WireConnection;178;3;83;0
WireConnection;29;0;26;0
WireConnection;29;1;30;0
WireConnection;31;0;29;0
WireConnection;90;0;178;0
WireConnection;102;0;103;0
WireConnection;102;1;104;0
WireConnection;127;0;125;0
WireConnection;179;1;102;0
WireConnection;179;2;105;0
WireConnection;179;3;101;0
WireConnection;128;0;119;0
WireConnection;126;0;127;0
WireConnection;126;1;128;0
WireConnection;107;0;179;0
WireConnection;122;1;124;0
WireConnection;123;0;126;0
WireConnection;123;1;122;0
WireConnection;39;0;37;0
WireConnection;177;1;92;0
WireConnection;177;2;97;0
WireConnection;177;3;98;0
WireConnection;172;0;170;0
WireConnection;172;1;171;0
WireConnection;56;0;52;0
WireConnection;56;1;57;0
WireConnection;170;0;169;0
WireConnection;4;0;7;0
WireConnection;4;1;8;0
WireConnection;131;0;107;0
WireConnection;40;0;38;0
WireConnection;40;1;41;0
WireConnection;13;0;4;0
WireConnection;130;0;100;0
WireConnection;42;0;40;0
WireConnection;92;0;94;0
WireConnection;92;1;95;0
WireConnection;52;0;53;0
WireConnection;52;1;51;0
WireConnection;32;0;19;0
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;19;0;17;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;176;1;172;0
WireConnection;176;2;174;0
WireConnection;176;3;173;0
WireConnection;58;0;56;0
WireConnection;169;0;167;0
WireConnection;169;1;168;0
WireConnection;100;0;177;0
WireConnection;53;0;50;0
WireConnection;53;1;51;0
WireConnection;33;0;35;0
WireConnection;33;1;34;0
WireConnection;61;0;63;0
WireConnection;61;1;64;0
WireConnection;61;2;60;0
WireConnection;167;0;165;0
WireConnection;167;1;166;0
WireConnection;65;0;61;0
WireConnection;36;0;33;0
WireConnection;36;1;37;0
WireConnection;60;0;58;0
WireConnection;60;1;57;0
WireConnection;38;0;36;0
WireConnection;38;1;39;0
WireConnection;7;0;6;0
WireConnection;121;0;123;0
WireConnection;121;1;120;0
WireConnection;0;0;121;0
ASEEND*/
//CHKSM=BF14AB75FB983E142D9AE386BE570AE2B4AB3EAF