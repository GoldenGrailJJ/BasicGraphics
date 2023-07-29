// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PLightingModel"
{
	Properties
	{
		_BlinPhongExp("BlinPhongExp", Float) = 1
		_BlinPhongScale("BlinPhongScale", Float) = 1

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
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

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
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
				float3 N6 = ase_worldNormal;
				float3 L13 = float3( 0,0,0 );
				float3 V14 = float3( 0,0,0 );
				float3 normalizeResult16 = normalize( ( L13 + V14 ) );
				float3 H17 = normalizeResult16;
				float dotResult128 = dot( N6 , H17 );
				float4 temp_cast_0 = (( pow( dotResult128 , _BlinPhongExp ) * _BlinPhongScale )).xxxx;
				
				
				finalColor = temp_cast_0;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
10;470.6667;1453.333;419.6667;-310.3454;-1258.859;1.261677;True;True
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-826.3454,856.4587;Inherit;False;L;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-836.7448,1009.859;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-531.2451,933.159;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;16;-301.1452,946.1589;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;5;-922.2578,214.3034;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-87.94537,952.6588;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-480.2582,272.3035;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;713.9785,1311.386;Inherit;False;6;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;720.9785,1434.386;Inherit;False;17;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;127;1002.978,1457.386;Inherit;False;Property;_BlinPhongExp;BlinPhongExp;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;128;1025.978,1344.386;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;1014.978,1536.386;Inherit;False;Property;_BlinPhongScale;BlinPhongScale;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-540.2579,37.30334;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;941.3196,678.2856;Inherit;False;4;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;935.4943,811.1425;Inherit;False;12;R;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;123;1247.494,702.1425;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;1174.494,882.1425;Inherit;False;Constant;_PhongExp;PhongExp;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;927.1026,213.6983;Inherit;False;14;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;121;1241.494,989.1425;Inherit;False;Constant;_PhongScale;PhongScale;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;583.8874,15.97207;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;10;-408.0134,495.8793;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;91;1345.398,333.8162;Inherit;False;Property;_CheapSSSScale;CheapSSSScale;7;0;Create;True;0;0;0;False;0;False;1;2.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;84;997.7607,100.6447;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;85;1154.621,130.321;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;755.1375,4655.948;Inherit;False;12;R;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;113;1643.138,4746.615;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;117;2114.138,4752.615;Inherit;False;PowerScale;-1;;9;5cedd72bdccd29f469a68b6308c49899;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;1864.138,4998.615;Inherit;False;Property;_Float8;Float 8;5;0;Create;True;0;0;0;False;0;False;1;4.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;114;1870.138,4756.615;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;1116.467,314.0325;Inherit;False;Property;_CheapSSSexp;CheapSSSexp;0;0;Create;True;0;0;0;False;0;False;1;47.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;801.3315,55.42324;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-187.0132,552.8793;Inherit;False;R;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;8;-584.0135,421.8795;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;1017.138,4652.615;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;130;1240.978,1357.386;Inherit;False;PowerScale;-1;;13;5cedd72bdccd29f469a68b6308c49899;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;233.4245,113.4787;Inherit;False;Property;_CheapSSSShift;CheapSSSShift;3;0;Create;True;0;0;0;False;0;False;1;10.63;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;721.1376,4931.948;Inherit;False;2;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;2400.979,4703.984;Inherit;False;CheapSSS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1;-933.3271,-191.2494;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;112;1589.138,4894.615;Inherit;False;14;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;2;-555.2579,-147.6966;Inherit;False;L;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;1226.016,4708.684;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-919.0136,387.8795;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-919.748,-12.44159;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;107;762.1375,4749.615;Inherit;False;Property;_Float7;Float 7;1;0;Create;True;0;0;0;False;0;False;0;1.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;233.0304,-18.22275;Inherit;False;6;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;124;1591.494,719.1425;Inherit;False;PowerScale;-1;;1;5cedd72bdccd29f469a68b6308c49899;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;111;1395.016,4729.684;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;92;1523.455,135.9738;Inherit;False;PowerScale;-1;;8;5cedd72bdccd29f469a68b6308c49899;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;1869.138,4876.615;Inherit;False;Property;_CheapSSSExp;CheapSSSExp;2;0;Create;True;0;0;0;False;0;False;1;12.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;239.4712,253.6631;Inherit;False;2;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;11;-900.0136,560.8793;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;1504.241,1375.22;Inherit;False;BlinPhong;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2434.361,1252.078;Float;False;True;-1;2;ASEMaterialInspector;100;1;PLightingModel;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;16;0;15;0
WireConnection;17;0;16;0
WireConnection;6;0;5;0
WireConnection;128;0;126;0
WireConnection;128;1;125;0
WireConnection;4;0;3;0
WireConnection;123;0;120;0
WireConnection;123;1;119;0
WireConnection;81;0;79;0
WireConnection;81;1;80;0
WireConnection;10;0;8;0
WireConnection;10;1;11;0
WireConnection;84;0;83;0
WireConnection;85;0;84;0
WireConnection;85;1;86;0
WireConnection;113;0;111;0
WireConnection;117;1;114;0
WireConnection;117;2;116;0
WireConnection;117;3;115;0
WireConnection;114;0;113;0
WireConnection;114;1;112;0
WireConnection;83;0;81;0
WireConnection;83;1;78;0
WireConnection;12;0;10;0
WireConnection;8;0;7;0
WireConnection;109;0;106;0
WireConnection;109;1;107;0
WireConnection;130;1;128;0
WireConnection;130;2;127;0
WireConnection;130;3;129;0
WireConnection;118;0;117;0
WireConnection;2;0;1;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;124;1;123;0
WireConnection;124;2;122;0
WireConnection;124;3;121;0
WireConnection;111;0;110;0
WireConnection;92;1;85;0
WireConnection;92;2;90;0
WireConnection;92;3;91;0
WireConnection;0;0;130;0
ASEEND*/
//CHKSM=121CF5FD5854236342136070364C65809987F958