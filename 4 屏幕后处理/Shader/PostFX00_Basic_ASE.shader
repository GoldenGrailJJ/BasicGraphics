// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/PostFX/Basic_ASE"
{
	Properties
	{
		_VignetteIntensity("VignetteIntensity", Float) = 1
		_VignetteExp("VignetteExp", Float) = 1
		_Color0("Color 0", Color) = (0,0,0,0)
		[HideInInspector]_MainTex("_MainTex", 2D) = "white" {}
		_Hue("Hue", Range( -100 , 100)) = 0
		_Saturation("Saturation", Range( -100 , 100)) = 0
		_Vaue("Vaue", Range( -100 , 100)) = 0
		[Toggle(_DISCO_ON)] _Disco("Disco", Float) = 0
		[KeywordEnum(None,Vignette,ColorModify)] _Type("Type", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
			#pragma multi_compile_local _TYPE_NONE _TYPE_VIGNETTE _TYPE_COLORMODIFY
			#pragma shader_feature_local _DISCO_ON


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
			uniform float4 _MainTex_ST;
			uniform float4 _Color0;
			uniform float _VignetteExp;
			uniform float _VignetteIntensity;
			uniform float _Hue;
			uniform float _Saturation;
			uniform float _Vaue;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode24 = tex2D( _MainTex, uv_MainTex );
				float4 SceneColor56 = tex2DNode24;
				float2 texCoord5 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break10 = ( texCoord5 - float2( 0.5,0.5 ) );
				float2 appendResult13 = (float2(break10.x , ( break10.y * ( _ScreenParams.y / _ScreenParams.x ) )));
				float4 lerpResult18 = lerp( _Color0 , tex2DNode24 , saturate( ( pow( ( 1.0 - length( appendResult13 ) ) , _VignetteExp ) * _VignetteIntensity ) ));
				float4 Vignette54 = lerpResult18;
				float3 hsvTorgb29 = RGBToHSV( tex2D( _MainTex, uv_MainTex ).rgb );
				float mulTime45 = _Time.y * 0.3;
				#ifdef _DISCO_ON
				float staticSwitch62 = ( ( ( frac( mulTime45 ) - 0.5 ) * 2.0 ) - 1.0 );
				#else
				float staticSwitch62 = ( _Hue * 0.01 );
				#endif
				float3 hsvTorgb30 = HSVToRGB( float3(( hsvTorgb29.x + staticSwitch62 ),( hsvTorgb29.y + ( _Saturation * 0.01 ) ),( hsvTorgb29.z + ( _Vaue * 0.01 ) )) );
				float3 ColorModify55 = hsvTorgb30;
				#if defined(_TYPE_NONE)
				float4 staticSwitch64 = SceneColor56;
				#elif defined(_TYPE_VIGNETTE)
				float4 staticSwitch64 = Vignette54;
				#elif defined(_TYPE_COLORMODIFY)
				float4 staticSwitch64 = float4( ColorModify55 , 0.0 );
				#else
				float4 staticSwitch64 = SceneColor56;
				#endif
				
				
				finalColor = staticSwitch64;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-209.3333;892;1693.333;925.6667;1277.164;93.27695;2.559046;True;True
Node;AmplifyShaderEditor.CommentaryNode;65;-1503.765,-239.9904;Inherit;False;2477.409;1167.058;暗角;15;4;15;17;21;20;16;27;22;19;24;18;56;54;23;26;暗角;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;4;-1453.765,310.6545;Inherit;False;1055.7;616.4124;分辨率纠正;6;13;10;8;7;6;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-1285.315,1080.792;Inherit;False;2436.75;1276.692;简单的调色;23;34;41;40;37;38;42;39;55;30;33;31;32;29;52;51;25;28;47;46;48;45;53;62;简单的调色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;7;-1394.849,639.7537;Inherit;False;795.0565;287.3131;考虑屏幕宽高比;3;12;11;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1403.765,360.6545;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;6;-1389.394,503.6025;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;-1095.164,411.5535;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1257.246,1425.823;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;9;-1344.849,723.6387;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-994.8504,742.6387;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;10;-900.3644,417.8535;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;45;-1097.246,1425.823;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;46;-925.2457,1426.823;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-768.3642,689.7537;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-959.2457,1499.823;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-755.8194,-11.83181;Inherit;True;Property;_MainTex;_MainTex;3;1;[HideInInspector];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-478.3635,-7.60471;Inherit;False;MainTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-566.0641,417.7537;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;-792.2457,1433.823;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-734.3149,1193.656;Inherit;False;26;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LengthOpNode;15;-319.1815,414.6251;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-534.3411,2047.023;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-687.0481,1615.792;Inherit;False;Property;_Hue;Hue;4;0;Create;True;0;0;0;False;0;False;0;-55;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-636.2457,1426.823;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-168.3324,545.5552;Inherit;False;Property;_VignetteExp;VignetteExp;1;0;Create;True;0;0;0;False;0;False;1;2.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-384.3411,1613.023;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;52;-410.2458,1413.823;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-173.3324,653.5552;Inherit;False;Property;_VignetteIntensity;VignetteIntensity;0;0;Create;True;0;0;0;False;0;False;1;17.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-588.0482,1870.792;Inherit;False;Property;_Saturation;Saturation;5;0;Create;True;0;0;0;False;0;False;0;26;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-547.2506,1193.313;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;17;-139.8555,410.2096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-585.0482,1958.792;Inherit;False;Property;_Vaue;Vaue;6;0;Create;True;0;0;0;False;0;False;0;1;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;16;99.14453,413.5975;Inherit;False;PowerScale;-1;;1;240e17d62fabf46488b4d5d44fa65237;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-205.3635,136.3953;Inherit;False;26;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RGBToHSVNode;29;-168.0482,1193.792;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-209.3411,1959.023;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;62;-207.5607,1415.738;Inherit;False;Property;_Disco;Disco;7;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-194.3411,1830.023;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;227.9518,1439.792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;2.230591,135.9932;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;22;320.6676,428.5552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;221.9518,1130.792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;221.9518,1290.792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;4.069878,-112.7825;Inherit;False;Property;_Color0;Color 0;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;18;503.6676,115.5552;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;30;536.9518,1135.792;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;945.3019,1129.615;Inherit;False;ColorModify;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;487.7896,-189.9904;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;727.3589,104.4886;Inherit;False;Vignette;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;1344.79,127.0096;Inherit;False;56;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;1328.606,328.6115;Inherit;False;55;ColorModify;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;1336.79,235.0096;Inherit;False;54;Vignette;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;66;1726.671,365.1692;Inherit;False;Constant;_Float3;Float 3;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;64;1670.606,175.6115;Inherit;False;Property;_Type;Type;8;0;Create;True;0;0;0;False;0;False;1;0;1;True;;KeywordEnum;3;None;Vignette;ColorModify;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2018.242,206.968;Float;False;True;-1;2;ASEMaterialInspector;100;1;TA/PostFX/Basic_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;8;0;5;0
WireConnection;8;1;6;0
WireConnection;11;0;9;2
WireConnection;11;1;9;1
WireConnection;10;0;8;0
WireConnection;45;0;53;0
WireConnection;46;0;45;0
WireConnection;12;0;10;1
WireConnection;12;1;11;0
WireConnection;26;0;23;0
WireConnection;13;0;10;0
WireConnection;13;1;12;0
WireConnection;47;0;46;0
WireConnection;47;1;48;0
WireConnection;15;0;13;0
WireConnection;51;0;47;0
WireConnection;39;0;34;0
WireConnection;39;1;42;0
WireConnection;52;0;51;0
WireConnection;25;0;28;0
WireConnection;17;0;15;0
WireConnection;16;1;17;0
WireConnection;16;2;20;0
WireConnection;16;3;21;0
WireConnection;29;0;25;0
WireConnection;41;0;38;0
WireConnection;41;1;42;0
WireConnection;62;1;39;0
WireConnection;62;0;52;0
WireConnection;40;0;37;0
WireConnection;40;1;42;0
WireConnection;33;0;29;3
WireConnection;33;1;41;0
WireConnection;24;0;27;0
WireConnection;22;0;16;0
WireConnection;31;0;29;1
WireConnection;31;1;62;0
WireConnection;32;0;29;2
WireConnection;32;1;40;0
WireConnection;18;0;19;0
WireConnection;18;1;24;0
WireConnection;18;2;22;0
WireConnection;30;0;31;0
WireConnection;30;1;32;0
WireConnection;30;2;33;0
WireConnection;55;0;30;0
WireConnection;56;0;24;0
WireConnection;54;0;18;0
WireConnection;64;1;57;0
WireConnection;64;0;58;0
WireConnection;64;2;63;0
WireConnection;0;0;64;0
ASEEND*/
//CHKSM=D4849327C1CFD989C2C4FE6279ACA65D26C46BE7