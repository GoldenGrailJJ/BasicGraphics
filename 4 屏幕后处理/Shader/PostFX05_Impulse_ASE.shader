// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/PostFX/Impulse_ASE"
{
	Properties
	{
		[HideInInspector]_MainTex("_MainTex", 2D) = "white" {}
		_FadeOut("FadeOut", Range( 0 , 1)) = 0
		_BlurIntensity("BlurIntensity", Float) = 1
		_ShakeIntensity("ShakeIntensity", Range( 0 , 1)) = 0

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

			uniform float _ShakeIntensity;
			uniform float _BlurIntensity;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _FadeOut;
			float4 RadiusBlur72( float2 uv, float2 center, float BlurIntensity, sampler2D _MainTex )
			{
				float2 dir =uv - center;
				float4 RadiusBlurColor = 0;
				int SampleCount = 8;
				for(int i=0;i<SampleCount;i++)
				{
				    float2 uvRadius = uv+dir*i*0.01*BlurIntensity;
				    RadiusBlurColor += tex2D(_MainTex,uvRadius);
				}
				RadiusBlurColor /= SampleCount;
				return RadiusBlurColor;
			}
			

			
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
				float2 texCoord56 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_13_0_g16 = frac( _Time.y );
				float temp_output_14_0_g16 = 0.03;
				float2 texCoord50 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 HitPoint85 = float2( 0.5,0.5 );
				float2 break52 = ( texCoord50 - HitPoint85 );
				float2 appendResult53 = (float2(break52.x , ( break52.y * ( _ScreenParams.y / _ScreenParams.x ) )));
				float temp_output_1_0_g16 = length( appendResult53 );
				float smoothstepResult10_g16 = smoothstep( ( temp_output_13_0_g16 - temp_output_14_0_g16 ) , temp_output_13_0_g16 , temp_output_1_0_g16);
				float smoothstepResult11_g16 = smoothstep( temp_output_13_0_g16 , ( temp_output_13_0_g16 + temp_output_14_0_g16 ) , temp_output_1_0_g16);
				float2 UVDir61 = appendResult53;
				float dotResult8_g11 = dot( ( UVDir61 * floor( ( _Time.y % 1000.0 ) ) ) , float2( 127.1,311.7 ) );
				float UV_Circle125 = ( ( smoothstepResult10_g16 - smoothstepResult11_g16 ) * 0.01 * 2.0 * (0.8 + (frac( ( sin( dotResult8_g11 ) * 43758.55 ) ) - 0.0) * (1.2 - 0.8) / (1.0 - 0.0)) );
				float2 temp_cast_0 = (3.3).xx;
				float mulTime5_g13 = _Time.y * 100.0;
				float dotResult8_g13 = dot( ( temp_cast_0 * floor( ( mulTime5_g13 % 1000.0 ) ) ) , float2( 127.1,311.7 ) );
				float2 temp_cast_1 = (7.7).xx;
				float mulTime5_g12 = _Time.y * 100.0;
				float dotResult8_g12 = dot( ( temp_cast_1 * floor( ( mulTime5_g12 % 1000.0 ) ) ) , float2( 127.1,311.7 ) );
				float2 appendResult95 = (float2(frac( ( sin( dotResult8_g13 ) * 43758.55 ) ) , frac( ( sin( dotResult8_g12 ) * 43758.55 ) )));
				float2 UV_ScreenShake123 = ( appendResult95 * 0.01 * _ShakeIntensity );
				float2 uv72 = ( texCoord56 + UV_Circle125 + UV_ScreenShake123 );
				float2 center72 = HitPoint85;
				float BlurIntensity72 = _BlurIntensity;
				sampler2D _MainTex72 = _MainTex;
				float4 localRadiusBlur72 = RadiusBlur72( uv72 , center72 , BlurIntensity72 , _MainTex72 );
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 lerpResult78 = lerp( localRadiusBlur72 , tex2D( _MainTex, uv_MainTex ) , _FadeOut);
				
				
				finalColor = lerpResult78;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
166.8571;412.5714;1802.857;774.4286;641.3352;588.693;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;89;-2508.88,-434.8422;Inherit;False;262.5715;211.8571;可以使用代码传入参数进来;1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;2;-2458.88,-384.8422;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;103;-2784.325,-174.6265;Inherit;False;2042.284;564.3214;冲击波 圈;17;60;59;58;41;5;40;61;53;52;51;86;50;125;127;44;42;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-2213.523,-386.0586;Inherit;False;HitPoint;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-2720.638,-72.21793;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2679.992,42.24545;Inherit;False;85;HitPoint;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2413.64,-42.21806;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenParams;42;-2679.325,197.2664;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-2329.327,216.2665;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;52;-2243.642,-43.21806;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2099.843,188.3818;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-1927.642,-46.21806;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;98;-2148.404,865.2537;Inherit;False;1311.885;406.5717;镜头晃动;10;91;92;95;99;101;102;97;96;93;123;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-1739.86,-124.6265;Inherit;False;UVDir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2027.112,420.5161;Inherit;False;745.4425;231.5714;加点噪音;3;71;100;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2092.984,923.2537;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;3.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-2094.859,1130.133;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;0;False;0;False;7.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;40;-1826.027,55.90342;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-2004.172,455.3314;Inherit;False;61;UVDir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-2098.404,1018.076;Inherit;False;Constant;_Float6;Float 6;3;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;102;-1822.125,938.2794;Inherit;False;RandomNoiseWithTime;-1;;13;89dbdb40ebccca846ad1944d230cfa63;0;2;1;FLOAT2;1,0;False;15;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;41;-1651.027,53.90343;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;100;-1792.813,462.8692;Inherit;False;RandomNoiseWithTime;-1;;11;89dbdb40ebccca846ad1944d230cfa63;0;2;1;FLOAT2;1,0;False;15;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;5;-1656.338,-23.38933;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;101;-1841.589,1085.133;Inherit;False;RandomNoiseWithTime;-1;;12;89dbdb40ebccca846ad1944d230cfa63;0;2;1;FLOAT2;1,0;False;15;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;71;-1472.476,463.4071;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.8;False;4;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1437.916,91.34174;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;-1476.984,971.2537;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;127;-1443.399,-25.76165;Inherit;False;SmoothCircle;-1;;16;09335d75282d8624480bf059199d8d18;0;3;1;FLOAT;0;False;13;FLOAT;0.3;False;14;FLOAT;0.03;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-1589.642,1168.958;Inherit;False;Property;_ShakeIntensity;ShakeIntensity;3;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1419.268,171.8519;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1492.978,1080.427;Inherit;False;Constant;_Float5;Float 5;3;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1231.09,931.6884;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;120;-1942.907,-485.0627;Inherit;False;556.8461;280;ScreenTex;2;76;117;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1212.615,-28.03229;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;76;-1892.907,-435.0627;Inherit;True;Property;_MainTex;_MainTex;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-1067.827,-34.33911;Inherit;False;UV_Circle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-1090.681,916.9293;Inherit;False;UV_ScreenShake;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-682.2538,-508.9198;Inherit;False;123;UV_ScreenShake;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-648.3333,-590.0611;Inherit;False;125;UV_Circle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-1637.347,-435.8405;Inherit;False;ScreenTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;-674.9082,-712.0687;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;119;-307.451,-124.3866;Inherit;False;117;ScreenTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;88;-99.59233,-484.9762;Inherit;False;308.5714;230.1429;自定义代码 径向模糊;1;72;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-312.3879,-567.3441;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-357.515,-38.48383;Inherit;False;0;76;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;87;-374.2125,-426.9018;Inherit;False;85;HitPoint;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-369.6866,-345.5569;Inherit;False;Property;_BlurIntensity;BlurIntensity;2;0;Create;True;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-385.933,-262.8531;Inherit;False;117;ScreenTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-68.95799,150.2593;Inherit;False;Property;_FadeOut;FadeOut;1;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-606.5151,1066.842;Inherit;False;745.4425;231.5714;加点噪音;3;147;146;145;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;77;-85.04849,-126.3027;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;72;-49.59234,-434.9762;Inherit;False;float2 dir =uv - center@$$float4 RadiusBlurColor = 0@$int SampleCount = 8@$for(int i=0@i<SampleCount@i++)${$    float2 uvRadius = uv+dir*i*0.01*BlurIntensity@$    RadiusBlurColor += tex2D(_MainTex,uvRadius)@$}$$RadiusBlurColor /= SampleCount@$return RadiusBlurColor@;4;False;4;False;uv;FLOAT2;0,0;In;;Inherit;False;False;center;FLOAT2;0,0;In;;Inherit;False;False;BlurIntensity;FLOAT;1;In;;Inherit;False;False;_MainTex;SAMPLER2D;_Sampler372;In;;Inherit;False;RadiusBlur;True;False;0;4;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;SAMPLER2D;_Sampler372;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FractNode;143;-409.009,830.062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;138;756.991,592.062;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;136;423.991,617.062;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-583.5751,1101.658;Inherit;False;61;UVDir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;149;285.5675,1176.931;Inherit;False;Property;_Vector2;Vector 2;5;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;135;229.991,1012.062;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;137;530.991,447.062;Inherit;False;117;ScreenTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;597.5675,786.9312;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-480.009,674.062;Inherit;False;Property;_Radius;Radius;4;0;Create;True;0;0;0;False;0;False;0;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;128;-694.1155,399.5294;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;142;-609.009,828.062;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;129;-656.5425,547.6105;Inherit;False;Constant;_Vector1;Vector 1;4;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;78;400.4669,-418.6332;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-171.009,686.062;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;147;-51.87891,1109.733;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.8;False;4;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;131;-167.009,479.062;Inherit;False;SmoothCircle;-1;;16;09335d75282d8624480bf059199d8d18;0;3;1;FLOAT;0;False;13;FLOAT;0.3;False;14;FLOAT;0.03;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;146;-372.2159,1109.195;Inherit;False;RandomNoiseWithTime;-1;;17;89dbdb40ebccca846ad1944d230cfa63;0;2;1;FLOAT2;1,0;False;15;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;116.991,517.062;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;130;-377.2719,402.526;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;652.702,-399.8264;Float;False;True;-1;2;ASEMaterialInspector;100;1;TA/PostFX/Impulse_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;55;-2729.325,113.3818;Inherit;False;795.0565;287.3131;考虑屏幕宽高比;0;;1,1,1,1;0;0
WireConnection;85;0;2;0
WireConnection;51;0;50;0
WireConnection;51;1;86;0
WireConnection;44;0;42;2
WireConnection;44;1;42;1
WireConnection;52;0;51;0
WireConnection;54;0;52;1
WireConnection;54;1;44;0
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;61;0;53;0
WireConnection;102;1;96;0
WireConnection;102;15;93;0
WireConnection;41;0;40;0
WireConnection;100;1;67;0
WireConnection;5;0;53;0
WireConnection;101;1;97;0
WireConnection;101;15;93;0
WireConnection;71;0;100;0
WireConnection;95;0;102;0
WireConnection;95;1;101;0
WireConnection;127;1;5;0
WireConnection;127;13;41;0
WireConnection;91;0;95;0
WireConnection;91;1;92;0
WireConnection;91;2;99;0
WireConnection;58;0;127;0
WireConnection;58;1;59;0
WireConnection;58;2;60;0
WireConnection;58;3;71;0
WireConnection;125;0;58;0
WireConnection;123;0;91;0
WireConnection;117;0;76;0
WireConnection;57;0;56;0
WireConnection;57;1;126;0
WireConnection;57;2;124;0
WireConnection;77;0;119;0
WireConnection;77;1;80;0
WireConnection;72;0;57;0
WireConnection;72;1;87;0
WireConnection;72;2;75;0
WireConnection;72;3;118;0
WireConnection;143;0;142;0
WireConnection;138;0;137;0
WireConnection;138;1;148;0
WireConnection;148;0;135;0
WireConnection;148;1;149;0
WireConnection;78;0;72;0
WireConnection;78;1;77;0
WireConnection;78;2;84;0
WireConnection;147;0;146;0
WireConnection;131;1;130;0
WireConnection;131;13;141;0
WireConnection;146;1;145;0
WireConnection;140;0;131;0
WireConnection;140;1;139;0
WireConnection;140;2;147;0
WireConnection;130;0;128;0
WireConnection;130;1;129;0
WireConnection;0;0;78;0
ASEEND*/
//CHKSM=5080FA5389DA5C3F2CF49C0655E1FAF14A14E5BC