// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/PostFX/Glitch_ASE"
{
	Properties
	{
		_BlockUV2Exp("BlockUV2Exp", Float) = 1
		_BlockUV1Exp("BlockUV1Exp", Float) = 1
		_BlockUVIntensity("BlockUVIntensity", Float) = 1
		_RGBSplitIntensity("RGBSplitIntensity", Float) = 0
		[HideInInspector]_MainTex("_MainTex", 2D) = "white" {}
		_BlockUV2("BlockUV2", Vector) = (1,1,0,0)
		_BlockUV1("BlockUV1", Vector) = (1,1,0,0)
		_TimeSpeed("TimeSpeed", Float) = 1
		[Toggle(_DEBUG_ON)] _Debug("Debug", Float) = 0

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
			#include "UnityShaderVariables.cginc"
			#pragma shader_feature_local _DEBUG_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
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

			uniform sampler2D _MainTex;
			uniform float2 _BlockUV1;
			uniform float _TimeSpeed;
			uniform float _BlockUV1Exp;
			uniform float2 _BlockUV2;
			uniform float _BlockUV2Exp;
			uniform float _BlockUVIntensity;
			uniform float _RGBSplitIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 texCoord44 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord46 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord3 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float TimeSpeed76 = _TimeSpeed;
				float mulTime2_g42 = _Time.y * TimeSpeed76;
				float dotResult11_g42 = dot( ( floor( ( texCoord3 * _BlockUV1 ) ) * floor( ( mulTime2_g42 % 1000.0 ) ) ) , float2( 19,21 ) );
				float2 texCoord6 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime2_g43 = _Time.y * TimeSpeed76;
				float dotResult11_g43 = dot( ( floor( ( texCoord6 * _BlockUV2 ) ) * floor( ( mulTime2_g43 % 1000.0 ) ) ) , float2( 19,21 ) );
				float2 temp_cast_0 = (5.1379).xx;
				float mulTime2_g45 = _Time.y * TimeSpeed76;
				float dotResult11_g45 = dot( ( temp_cast_0 * floor( ( mulTime2_g45 % 1000.0 ) ) ) , float2( 19,21 ) );
				float GlitchNoise42 = ( ( pow( frac( ( sin( dotResult11_g42 ) * 123.0 ) ) , _BlockUV1Exp ) * pow( frac( ( sin( dotResult11_g43 ) * 123.0 ) ) , _BlockUV2Exp ) * _BlockUVIntensity ) - ( pow( frac( ( sin( dotResult11_g45 ) * 123.0 ) ) , 7.1 ) * _RGBSplitIntensity ) );
				float4 appendResult16_g47 = (float4(TimeSpeed76 , 1.0 , 0.0 , 0.0));
				float mulTime9_g47 = _Time.y * 7.0;
				float dotResult12_g47 = dot( ( appendResult16_g47 * floor( ( mulTime9_g47 % 1000.0 ) ) ) , float4( float2( 19,21 ), 0.0 , 0.0 ) );
				float2 texCoord48 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult16_g48 = (float4(TimeSpeed76 , 1.0 , 0.0 , 0.0));
				float mulTime9_g48 = _Time.y * 23.0;
				float dotResult12_g48 = dot( ( appendResult16_g48 * floor( ( mulTime9_g48 % 1000.0 ) ) ) , float4( float2( 19,21 ), 0.0 , 0.0 ) );
				float4 appendResult64 = (float4(tex2D( _MainTex, texCoord44 ).r , tex2D( _MainTex, ( texCoord46 + ( ( GlitchNoise42 * frac( ( sin( dotResult12_g47 ) * 123.0 ) ) * 0.05 ) * float2( 1,0.5 ) ) ) ).g , tex2D( _MainTex, ( texCoord48 + ( ( GlitchNoise42 * frac( ( sin( dotResult12_g48 ) * 123.0 ) ) * 0.05 ) * float2( 1,-0.5 ) ) ) ).b , 1.0));
				float4 temp_cast_3 = (GlitchNoise42).xxxx;
				#ifdef _DEBUG_ON
				float4 staticSwitch69 = temp_cast_3;
				#else
				float4 staticSwitch69 = appendResult64;
				#endif
				
				
				finalColor = staticSwitch69;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-11.33333;516.6667;1693.333;1370.333;1138.879;-2585.279;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;97;-864.2109,-234.8634;Inherit;False;1417.441;736.2012;局部噪音;17;3;66;6;67;4;7;11;9;78;19;20;41;18;17;77;22;212;局部噪音;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-1595.154,-232.0861;Inherit;False;478.2858;166.2857;设置时间速度;2;75;76;设置时间速度;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-803.8776,-158.8634;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-1545.154,-182.0861;Inherit;False;Property;_TimeSpeed;TimeSpeed;7;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;66;-786.6924,-34.51927;Inherit;False;Property;_BlockUV1;BlockUV1;6;0;Create;True;0;0;0;False;0;False;1,1;11.95,17.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-808.2109,209.47;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;67;-782.6924,339.4807;Inherit;False;Property;_BlockUV2;BlockUV2;5;0;Create;True;0;0;0;False;0;False;1,1;4.8,5.96;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-517.8774,-155.8634;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-1363.154,-181.0861;Inherit;False;TimeSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-523.2108,210.4701;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;9;-356.6841,-155.5584;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-482.551,324.7106;Inherit;False;76;TimeSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-427.5598,-41.87355;Inherit;False;76;TimeSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;11;-381.3713,211.3609;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;98;-533.189,561.6298;Inherit;False;1008.118;348.2857;整体噪音;5;40;79;33;34;31;整体噪音;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-108.3713,-48.63913;Inherit;False;Property;_BlockUV1Exp;BlockUV1Exp;1;0;Create;True;0;0;0;False;0;False;1;1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;213;-220.8841,171.3965;Inherit;False;Random Noise With Time;-1;;43;28481c7ce31c0474c89127f9740a61f7;0;2;1;FLOAT;0;False;10;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-494.3249,638.2444;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;5.1379;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-506.1895,729.0045;Inherit;False;76;TimeSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-202.3713,300.3609;Inherit;False;Property;_BlockUV2Exp;BlockUV2Exp;0;0;Create;True;0;0;0;False;0;False;1;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;212;-209.2136,-168.1012;Inherit;True;Random Noise With Time;-1;;42;28481c7ce31c0474c89127f9740a61f7;0;2;1;FLOAT;0;False;10;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-104.7856,737.6298;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;7.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;215;-260.8096,626.4282;Inherit;False;Random Noise With Time;-1;;45;28481c7ce31c0474c89127f9740a61f7;0;2;1;FLOAT;0;False;10;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-160.7856,824.6298;Inherit;False;Property;_RGBSplitIntensity;RGBSplitIntensity;3;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;149.2144,597.6298;Inherit;False;277.7143;206.8572;整体噪音;1;32;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;22;25.56067,336.9066;Inherit;False;Property;_BlockUVIntensity;BlockUVIntensity;2;0;Create;True;0;0;0;False;0;False;1;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;17;109.6287,-146.6391;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;18;44.62872,192.0609;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;284.6592,-34.63913;Inherit;False;241.9714;265.3571;局部噪音;1;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;32;199.2144,647.6298;Inherit;False;PowerScale;-1;;35;240e17d62fabf46488b4d5d44fa65237;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;320.7519,8.49302;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1493.288,1562.332;Inherit;False;1480.14;539.1406;G通道UV偏移;10;53;62;80;55;52;46;91;54;95;217;G通道UV偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1004.582,2271.795;Inherit;False;1203.238;682.2854;B通道UV偏移;10;61;93;48;58;63;57;60;81;96;218;G通道UV偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;664.9168,370.4883;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-1061.816,2702.02;Inherit;False;76;TimeSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1034.366,2575.845;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;23;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;879.8472,381.8594;Inherit;False;GlitchNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1423.039,1771.055;Inherit;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;0;False;0;False;7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1451.288,1861.26;Inherit;False;76;TimeSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-626.9159,2707.795;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1114.569,1906.186;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;95;-835,1867;Inherit;False;250.5714;211.8572;偏移方向，可以设为参数;1;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;217;-1219.818,1798.317;Inherit;False;Random Noise With Time 1Input;-1;;47;c4408e257782f0a41b73b0d67d0205fe;0;2;2;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-676.8965,2508.352;Inherit;False;42;GlitchNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;96;-424.8193,2720.06;Inherit;False;255.7143;211.8572;偏移方向，可以设为参数;1;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-1132.619,1702.494;Inherit;False;42;GlitchNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;218;-846.1283,2602.594;Inherit;False;Random Noise With Time 1Input;-1;;48;c4408e257782f0a41b73b0d67d0205fe;0;2;2;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;94;-374.8193,2770.06;Inherit;False;Constant;_Vector1;Vector 1;9;0;Create;True;0;0;0;False;0;False;1,-0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-332.2753,2515.45;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;92;-785,1917;Inherit;False;Constant;_Vector0;Vector 0;9;0;Create;True;0;0;0;False;0;False;1,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-845.0092,1741.36;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-376.6012,1738.625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-605.9939,1649.966;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-351.4341,2314.78;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;65;-288.8247,1025.931;Inherit;False;301.2857;280;在材质面板中隐藏;1;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-134.8193,2507.06;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-200.1941,1322.219;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;30;-238.8245,1075.931;Inherit;True;Property;_MainTex;_MainTex;4;1;[HideInInspector];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;50;473.9783,1625.571;Inherit;False;371.1428;280;G;1;45;G;0,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-167.7201,1676.734;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;49;462.985,1177.963;Inherit;False;371.1428;280;R;1;43;R;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;11.0842,2321.795;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;51;489.0714,2184.681;Inherit;False;371.1429;280;B;1;47;B;0,0,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;47;539.0715,2234.681;Inherit;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;43;512.985,1227.963;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;523.9783,1675.571;Inherit;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;199;412.4122,-662.3832;Inherit;False;230;183;取余数，数字太大会溢出;1;206;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;1090.493,1895.42;Inherit;False;42;GlitchNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;1134.606,1719.009;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;202;888.4122,-552.3833;Inherit;False;Constant;_Vector3;Vector 0;0;0;Create;True;0;0;0;False;0;False;123,231;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;175;1832.455,3881.643;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;152;1356.685,2591.31;Inherit;False;Constant;_Vector2;Vector 2;10;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;171;1642.455,3629.643;Inherit;False;Property;_GOffset;GOffset;11;0;Create;True;0;0;0;False;0;False;0,0;0.01,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;151;1291.685,2429.31;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;183;1649.598,4296.656;Inherit;False;176;GlitchMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;188;-515.7692,-507.9214;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-953.7691,-342.9214;Inherit;False;Constant;_Float7;Float 7;13;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;1619.598,3826.656;Inherit;False;176;GlitchMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;2167.924,2451.378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;145;1916.172,2293.085;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;166;2258.455,3195.643;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-725.7692,-499.9214;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;2294.208,3092.723;Inherit;False;109;SceneTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;1966.598,4171.656;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;113.1788,1080.452;Inherit;False;SceneTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.Vector2Node;168;1687.455,3248.643;Inherit;False;Property;_ROffset;ROffset;10;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;179;1620.098,3408.156;Inherit;False;176;GlitchMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;162;2544.654,3776.038;Inherit;True;Property;_TextureSample6;Texture Sample 6;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;2256.184,2661.506;Inherit;False;GlitchMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;155;1877.071,2448.057;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;1744.092,-787.9185;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;147;1899.977,2703.931;Inherit;False;Property;_Vector0;Vector 0;9;0;Create;True;0;0;0;False;0;False;0,0;0.36,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StaticSwitch;69;1359.244,1713.688;Inherit;False;Property;_Debug;Debug;8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;1936.455,3524.643;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;161;2284.315,3423.021;Inherit;False;109;SceneTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.StickyNoteNode;99;-2212.546,2470.086;Inherit;False;150;100;参数数量;参数数量;1,0,0,1;参数不用设置太多，否则不方便调整效果$;0;0
Node;AmplifyShaderEditor.SamplerNode;158;2592.547,3095.74;Inherit;True;Property;_TextureSample4;Texture Sample 4;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;174;1680.455,4088.643;Inherit;False;Property;_BOffset;BOffset;12;0;Create;True;0;0;0;False;0;False;0,0;-0.01,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DotProductOpNode;208;1144.312,-744.3832;Inherit;True;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;149;2598.222,2172.105;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;148;2272.883,2178.088;Inherit;False;109;SceneTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FractNode;210;1949.092,-769.5184;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;214;-278.8591,-494.0928;Inherit;False;Random Noise With Time;-1;;44;28481c7ce31c0474c89127f9740a61f7;0;2;1;FLOAT;0;False;10;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;160;2582.654,3426.038;Inherit;True;Property;_TextureSample5;Texture Sample 5;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;154;1599.685,2441.31;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;1511.492,-632.5184;Inherit;False;Constant;_Float8;Float 1;0;0;Create;True;0;0;0;False;0;False;123;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;200;233.4122,-470.3833;Inherit;False;Constant;_Float3;Float 0;0;0;Create;True;0;0;0;False;0;False;1000;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;1936.598,3701.656;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;1937.098,3283.156;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;2246.315,3773.021;Inherit;False;109;SceneTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;2114.455,3905.643;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;146;2248.172,2318.085;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;165;1951.455,3090.643;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;203;1533.492,-783.5184;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;205;230.4122,-624.3832;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;206;463.7122,-611.0833;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;207;698.4122,-562.7833;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;2218.455,3548.643;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;164;3016.484,3451.529;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;185;-998.7691,-513.9214;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;1658.071,2660.057;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;844.4122,-753.3832;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1555.72,1670.284;Float;False;True;-1;2;ASEMaterialInspector;100;1;TA/PostFX/Glitch_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;123;2181.88,1914.517;Inherit;False;301;132;核心思想:1.对UV做偏移 2.RGB通道分离;0;核心思想:1.对UV做偏移 2.RGB通道分离;1,1,1,1;0;0
WireConnection;4;0;3;0
WireConnection;4;1;66;0
WireConnection;76;0;75;0
WireConnection;7;0;6;0
WireConnection;7;1;67;0
WireConnection;9;0;4;0
WireConnection;11;0;7;0
WireConnection;213;1;78;0
WireConnection;213;10;11;0
WireConnection;212;1;77;0
WireConnection;212;10;9;0
WireConnection;215;1;79;0
WireConnection;215;10;33;0
WireConnection;17;0;212;0
WireConnection;17;1;20;0
WireConnection;18;0;213;0
WireConnection;18;1;19;0
WireConnection;32;1;215;0
WireConnection;32;2;34;0
WireConnection;32;3;31;0
WireConnection;21;0;17;0
WireConnection;21;1;18;0
WireConnection;21;2;22;0
WireConnection;35;0;21;0
WireConnection;35;1;32;0
WireConnection;42;0;35;0
WireConnection;217;2;55;0
WireConnection;217;8;80;0
WireConnection;218;2;60;0
WireConnection;218;8;81;0
WireConnection;58;0;57;0
WireConnection;58;1;218;0
WireConnection;58;2;63;0
WireConnection;54;0;53;0
WireConnection;54;1;217;0
WireConnection;54;2;62;0
WireConnection;91;0;54;0
WireConnection;91;1;92;0
WireConnection;93;0;58;0
WireConnection;93;1;94;0
WireConnection;52;0;46;0
WireConnection;52;1;91;0
WireConnection;61;0;48;0
WireConnection;61;1;93;0
WireConnection;47;0;30;0
WireConnection;47;1;61;0
WireConnection;43;0;30;0
WireConnection;43;1;44;0
WireConnection;45;0;30;0
WireConnection;45;1;52;0
WireConnection;64;0;43;1
WireConnection;64;1;45;2
WireConnection;64;2;47;3
WireConnection;188;0;186;0
WireConnection;157;0;155;0
WireConnection;157;1;147;0
WireConnection;166;0;165;0
WireConnection;166;1;177;0
WireConnection;186;0;185;0
WireConnection;186;1;187;0
WireConnection;182;0;174;0
WireConnection;182;1;183;0
WireConnection;109;0;30;0
WireConnection;162;0;163;0
WireConnection;162;1;173;0
WireConnection;176;0;155;0
WireConnection;155;0;154;0
WireConnection;155;1;156;0
WireConnection;209;0;203;0
WireConnection;209;1;204;0
WireConnection;69;1;64;0
WireConnection;69;0;68;0
WireConnection;158;0;159;0
WireConnection;158;1;166;0
WireConnection;208;0;201;0
WireConnection;208;1;202;0
WireConnection;149;0;148;0
WireConnection;149;1;146;0
WireConnection;210;0;209;0
WireConnection;214;10;188;0
WireConnection;160;0;161;0
WireConnection;160;1;170;0
WireConnection;154;0;151;0
WireConnection;154;1;152;0
WireConnection;180;0;171;0
WireConnection;180;1;181;0
WireConnection;177;0;168;0
WireConnection;177;1;179;0
WireConnection;173;0;175;0
WireConnection;173;1;182;0
WireConnection;146;0;145;0
WireConnection;146;1;157;0
WireConnection;203;0;208;0
WireConnection;206;0;205;0
WireConnection;206;1;200;0
WireConnection;207;0;206;0
WireConnection;170;0;172;0
WireConnection;170;1;180;0
WireConnection;164;0;158;1
WireConnection;164;1;160;2
WireConnection;164;2;162;3
WireConnection;201;1;207;0
WireConnection;0;0;69;0
ASEEND*/
//CHKSM=A40457246AB3862E807E8E5C4B2174A52CBAF18A