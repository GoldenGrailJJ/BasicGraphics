// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/PostFX/Transition_ASE"
{
	Properties
	{
		[HideInInspector]_MainTex("_MainTex", 2D) = "white" {}
		_Transition("Transition", Range( 0 , 1)) = 0
		[KeywordEnum(Blend,Grid,Flip,Flip2,FlipPolar,FlipPolar2,CircleTransition,Noise,Noise2)] _Type("Type", Float) = 0
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
			#pragma shader_feature_local _TYPE_BLEND _TYPE_GRID _TYPE_FLIP _TYPE_FLIP2 _TYPE_FLIPPOLAR _TYPE_FLIPPOLAR2 _TYPE_CIRCLETRANSITION _TYPE_NOISE _TYPE_NOISE2


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
			uniform float _Transition;
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
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float4 SceneColor30 = tex2DNode1;
				float grayscale2 = Luminance(tex2DNode1.rgb);
				float2 texCoord22 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_2_0_g17 = 500.0;
				float2 temp_output_5_0_g17 = ( floor( ( texCoord22 * temp_output_2_0_g17 ) ) / temp_output_2_0_g17 );
				float dotResult6_g17 = dot( temp_output_5_0_g17 , temp_output_5_0_g17 );
				float mulTime9_g17 = _Time.y * 0.0;
				float2 temp_cast_1 = (( dotResult6_g17 * mulTime9_g17 )).xx;
				float dotResult4_g18 = dot( temp_cast_1 , float2( 12.9898,78.233 ) );
				float lerpResult10_g18 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g18 ) * 43758.55 ) ));
				float lerpResult26 = lerp( 0.8 , 1.0 , lerpResult10_g18);
				float TargetColor29 = ( grayscale2 * lerpResult26 );
				float4 temp_cast_2 = (TargetColor29).xxxx;
				float2 texCoord33 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 lerpResult34 = lerp( SceneColor30 , temp_cast_2 , texCoord33.x);
				float4 T1_Blend176 = lerpResult34;
				float4 temp_cast_3 = (TargetColor29).xxxx;
				float2 texCoord192 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break197 = ( floor( ( texCoord192 * 20.0 ) ) / 20.0 );
				float2 temp_cast_4 = (( ( break197.x + 3.0 ) * ( break197.y + 17.0 ) )).xx;
				float dotResult4_g25 = dot( temp_cast_4 , float2( 12.9898,78.233 ) );
				float lerpResult10_g25 = lerp( 0.01 , 1.0 , frac( ( sin( dotResult4_g25 ) * 43758.55 ) ));
				float Transition166 = _Transition;
				float4 lerpResult206 = lerp( SceneColor30 , temp_cast_3 , step( lerpResult10_g25 , Transition166 ));
				float4 T8_Grid218 = lerpResult206;
				float4 temp_cast_5 = (TargetColor29).xxxx;
				float2 texCoord39 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 lerpResult38 = lerp( SceneColor30 , temp_cast_5 , step( texCoord39.y , Transition166 ));
				float4 T2_Flip177 = lerpResult38;
				float4 temp_cast_6 = (TargetColor29).xxxx;
				float2 texCoord44 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_7 = ((-0.01 + (Transition166 - 0.0) * (1.0 - -0.01) / (1.0 - 0.0))).xx;
				float4 lerpResult49 = lerp( SceneColor30 , temp_cast_6 , float4( step( frac( ( texCoord44 * 10.0 ) ) , temp_cast_7 ), 0.0 , 0.0 ));
				float4 T3_Flip2178 = lerpResult49;
				float4 temp_cast_9 = (TargetColor29).xxxx;
				float2 texCoord56 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g23 = ( texCoord56 - float2( 0.5,0.5 ) );
				float2 break17_g23 = CenteredUV15_g23;
				float2 appendResult23_g23 = (float2(( length( CenteredUV15_g23 ) * 1.0 * 2.0 ) , ( atan2( break17_g23.x , break17_g23.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float4 lerpResult62 = lerp( SceneColor30 , temp_cast_9 , step( (0.0 + (appendResult23_g23.y - -0.5) * (1.0 - 0.0) / (0.5 - -0.5)) , Transition166 ));
				float4 T4_Polar179 = lerpResult62;
				float4 temp_cast_10 = (TargetColor29).xxxx;
				float2 texCoord76 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g24 = ( frac( ( texCoord76 * 2.0 ) ) - float2( 0.5,0.5 ) );
				float2 break17_g24 = CenteredUV15_g24;
				float2 appendResult23_g24 = (float2(( length( CenteredUV15_g24 ) * 1.0 * 2.0 ) , ( atan2( break17_g24.x , break17_g24.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float4 lerpResult86 = lerp( SceneColor30 , temp_cast_10 , step( (0.0 + (appendResult23_g24.y - -0.5) * (1.0 - 0.0) / (0.5 - -0.5)) , Transition166 ));
				float4 T4_Polar2180 = lerpResult86;
				float4 temp_cast_11 = (TargetColor29).xxxx;
				float2 texCoord100 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break105 = ( texCoord100 - float2( 0.5,0.5 ) );
				float2 appendResult107 = (float2(break105.x , ( break105.y * ( _ScreenParams.y / _ScreenParams.x ) )));
				float4 lerpResult91 = lerp( SceneColor30 , temp_cast_11 , step( length( appendResult107 ) , Transition166 ));
				float4 T5_CircleTransition181 = lerpResult91;
				float4 temp_cast_12 = (TargetColor29).xxxx;
				float2 texCoord110 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float simpleNoise111 = SimpleNoise( ( texCoord110 * 30.0 ) );
				float4 lerpResult116 = lerp( SceneColor30 , temp_cast_12 , step( simpleNoise111 , Transition166 ));
				float4 T6_Noise182 = lerpResult116;
				float4 temp_cast_13 = (TargetColor29).xxxx;
				float2 texCoord144 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float simpleNoise147 = SimpleNoise( ( texCoord144 * 30.0 ) );
				float temp_output_151_0 = step( simpleNoise147 , Transition166 );
				float4 lerpResult158 = lerp( SceneColor30 , temp_cast_13 , temp_output_151_0);
				float4 color155 = IsGammaSpace() ? float4(0.05102638,0.5098807,0.8113208,0) : float4(0.004028909,0.2233008,0.6231937,0);
				float4 T7_Noise2183 = ( lerpResult158 + ( ( step( simpleNoise147 , ( Transition166 + 0.0125 ) ) - temp_output_151_0 ) * color155 ) );
				#if defined(_TYPE_BLEND)
				float4 staticSwitch174 = T1_Blend176;
				#elif defined(_TYPE_GRID)
				float4 staticSwitch174 = T8_Grid218;
				#elif defined(_TYPE_FLIP)
				float4 staticSwitch174 = T2_Flip177;
				#elif defined(_TYPE_FLIP2)
				float4 staticSwitch174 = T3_Flip2178;
				#elif defined(_TYPE_FLIPPOLAR)
				float4 staticSwitch174 = T4_Polar179;
				#elif defined(_TYPE_FLIPPOLAR2)
				float4 staticSwitch174 = T4_Polar2180;
				#elif defined(_TYPE_CIRCLETRANSITION)
				float4 staticSwitch174 = T5_CircleTransition181;
				#elif defined(_TYPE_NOISE)
				float4 staticSwitch174 = T6_Noise182;
				#elif defined(_TYPE_NOISE2)
				float4 staticSwitch174 = T7_Noise2183;
				#else
				float4 staticSwitch174 = T1_Blend176;
				#endif
				
				
				finalColor = staticSwitch174;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
74;126.6667;1693.333;837;2233.559;792.025;1.850513;True;True
Node;AmplifyShaderEditor.CommentaryNode;217;165.317,5219.516;Inherit;False;1991.617;582.6919;格子;17;200;201;205;204;203;206;216;214;213;215;209;193;192;194;195;196;197;格子;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;193;266.3498,5557.847;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;214.6685,2580.783;Inherit;False;1836.025;766.1309;圆形过渡;7;108;89;90;91;97;95;171;圆形过渡;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;192;204.317,5420.942;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;37;-1299.672,-380.5754;Inherit;False;1440.681;616.3732;源场景颜色 目标场景颜色;9;22;23;26;30;2;7;29;1;245;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;477.3496,5459.847;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;108;264.6685,2730.502;Inherit;False;1055.7;616.4124;分辨率纠正;6;99;94;100;103;105;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;88;239.021,1772.383;Inherit;False;1831.001;715.7677;翻页 极坐标2;12;84;77;85;83;79;80;81;86;75;76;78;170;翻页 极坐标2;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1119.545,120.5121;Inherit;False;Constant;_Float5;Float 5;1;0;Create;True;0;0;0;False;0;False;500;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-1143.545,-26.48783;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;160;286.0034,4106.728;Inherit;False;1792.46;995.5381;噪音溶解2;16;161;159;154;158;156;157;155;152;151;147;150;146;149;144;145;173;噪音溶解2;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;289.021,2018.535;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;165;1328.318,-1119.673;Inherit;False;Property;_Transition;Transition;1;0;Create;True;0;0;0;False;0;False;0;0.59;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;195;640.6724,5451.878;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;314.6685,2780.502;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;99;323.5836,3059.601;Inherit;False;795.0565;287.3131;考虑屏幕宽高比;3;106;104;102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;94;329.0395,2923.45;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;75;384.0145,2155.148;Inherit;False;Constant;_Float8;Float 8;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;102;373.5836,3143.486;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;623.2687,2831.401;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1263.672,-330.5754;Inherit;True;Property;_MainTex;_MainTex;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;562.0144,2091.148;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;245;-828.9675,54.987;Inherit;False;White Noise;-1;;17;7cc518f4f6ff3304fbef5d945e718139;0;3;8;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;388.0363,4404.466;Inherit;False;Constant;_Float17;Float 17;6;0;Create;True;0;0;0;False;0;False;30;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;144;273.0034,4275.561;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;196;775.6722,5455.878;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;1656.318,-1115.673;Inherit;False;Transition;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;-497.5451,-65.98789;Inherit;False;3;0;FLOAT;0.8;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;922.831,5578.7;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;197;917.6721,5454.878;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;55;886.9544,525.4164;Inherit;False;1206;539.7578;翻页2;9;44;51;50;52;48;46;49;47;168;翻页2;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;671.1498,4592.931;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;119;956.6485,3433.527;Inherit;False;1074.761;622.3118;噪音溶解;9;110;113;112;111;114;115;118;116;172;噪音溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCGrayscale;2;-811.9813,-183.5883;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;87;769.1721,1157.547;Inherit;False;1282.701;565.1683;翻页 极坐标;8;61;60;62;68;71;67;70;169;翻页 极坐标;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;104;723.5827,3162.486;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;105;802.0687,2838.701;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;149;797.7582,4703.14;Inherit;False;Constant;_Float19;Float 19;3;0;Create;True;0;0;0;False;0;False;0.0125;0.0125;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;930.831,5692.7;Inherit;False;Constant;_Float9;Float 9;3;0;Create;True;0;0;0;False;0;False;17;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;523.1721,1373.099;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;78;772.0144,2081.148;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;555.0361,4314.466;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;147;710.0362,4294.466;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;886.9544,775.5685;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;79;960.014,2069.148;Inherit;False;Polar Coordinates;-1;;24;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;1139.83,5607.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;995.524,938.8885;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;67;809.365,1396.812;Inherit;False;Polar Coordinates;-1;;23;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;950.0689,3109.601;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-310.3808,-174.1628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;213;1136.83,5486.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;1072.681,3816.954;Inherit;False;Constant;_Float7;Float 7;6;0;Create;True;0;0;0;False;0;False;30;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;110;1006.648,3694.048;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;150;1044.757,4591.14;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;161;1355.062,4434.837;Inherit;False;225.4286;183.5713;颜色边;1;153;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;1286.83,5493.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-826.6251,-336.24;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;54;1063.888,-56.19043;Inherit;False;956.326;558.4682;翻页;6;167;38;40;41;42;39;翻页;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;1211.318,972.3269;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-105.2773,-173.193;Inherit;False;TargetColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;152;1170.429,4499.247;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;80;1254.014,2090.148;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;107;1075.369,2826.601;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;1272.524,822.8885;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;1283.681,3705.954;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;151;1088.495,4311.065;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;68;1064.865,1388.712;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;111;1443.681,3712.954;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;1169.214,222.9617;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;156;1238.587,4128.728;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;1448.383,5682.922;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;153;1405.062,4484.837;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;1226.427,4228.154;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;155;1326.062,4664.837;Inherit;False;Constant;_Color1;Color 1;3;1;[HDR];Create;True;0;0;0;False;0;False;0.05102638,0.5098807,0.8113208,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;53;1172.703,-540.7126;Inherit;False;797.6423;394.0093;融合;4;34;32;33;31;融合;1,1,1,1;0;0
Node;AmplifyShaderEditor.LengthOpNode;95;1474.74,2840.25;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;1440.318,1603.327;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;1483.318,3957.327;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;70;1454.865,1408.712;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;1472.318,2321.327;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;81;1468.014,2104.148;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;1191.318,392.3269;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;1411.318,3058.327;Inherit;False;166;Transition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;239;1425.258,959.9734;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.01;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;200;1510.268,5488.201;Inherit;False;Random Range;-1;;25;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.01;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;52;1433.524,824.8885;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;1430.177,3582.953;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;1627.862,5269.516;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;1209.142,-6.19043;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;1456.801,1207.547;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;1485.723,674.8422;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;1669.062,4530.837;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;1442.337,3483.527;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;47;1640.429,864.4989;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;1196.982,93.23544;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;118;1721.141,3745.553;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;1464.95,1822.383;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;1452.79,1921.809;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;1497.883,575.4164;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;1615.702,5368.942;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;1455.622,2630.783;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;71;1765.865,1422.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;1264.631,-490.7126;Inherit;False;30;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;1222.703,-286.5605;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;83;1689.014,2108.148;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;1251.471,-391.2867;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;203;1817.383,5507.922;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;1444.641,1306.973;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;158;1557.659,4168.88;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;97;1678.14,2850.451;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;42;1470.888,235.9921;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;1443.462,2730.209;Inherit;False;29;TargetColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;38;1818.214,76.96167;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;49;1906.955,639.5685;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;34;1727.703,-426.5605;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;91;1864.694,2694.935;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;116;1845.409,3505.679;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;62;1865.873,1271.699;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;206;1970.934,5359.668;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;86;1874.022,1886.535;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;1806.891,4358.587;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;2155.064,2697.423;Inherit;False;T5_CircleTransition;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;177;2085.954,66.61572;Inherit;False;T2_Flip;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;2219.396,5277.805;Inherit;False;T8_Grid;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;2149.449,1853.237;Inherit;False;T4_Polar2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;2143.954,646.6157;Inherit;False;T3_Flip2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;179;2104.718,1257.035;Inherit;False;T4_Polar;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;2139.387,4366.341;Inherit;False;T7_Noise2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;2114.132,3496.315;Inherit;False;T6_Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;1998.954,-434.3843;Inherit;False;T1_Blend;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;2774.623,-430.3784;Inherit;False;218;T8_Grid;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;2745.623,128.6216;Inherit;False;183;T7_Noise2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;2772.623,-191.3784;Inherit;False;179;T4_Polar;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;2776.253,-511.2154;Inherit;False;176;T1_Blend;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;2704.623,-32.3784;Inherit;False;181;T5_CircleTransition;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;2768.623,-264.3784;Inherit;False;178;T3_Flip2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;2773.623,-347.3784;Inherit;False;177;T2_Flip;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;2759.623,-111.3784;Inherit;False;180;T4_Polar2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;2756.623,53.6216;Inherit;False;182;T6_Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;174;3168.253,-318.2155;Inherit;False;Property;_Type;Type;2;0;Create;True;0;0;0;False;0;False;0;0;1;True;;KeywordEnum;9;Blend;Grid;Flip;Flip2;FlipPolar;FlipPolar2;CircleTransition;Noise;Noise2;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3577.698,-341.1361;Float;False;True;-1;2;ASEMaterialInspector;100;1;TA/PostFX/Transition_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;24;-1292.286,491.6428;Inherit;False;1399;336.2857;白噪音;0;;1,1,1,1;0;0
WireConnection;194;0;192;0
WireConnection;194;1;193;0
WireConnection;195;0;194;0
WireConnection;103;0;100;0
WireConnection;103;1;94;0
WireConnection;77;0;76;0
WireConnection;77;1;75;0
WireConnection;245;1;22;0
WireConnection;245;2;23;0
WireConnection;196;0;195;0
WireConnection;196;1;193;0
WireConnection;166;0;165;0
WireConnection;26;2;245;0
WireConnection;197;0;196;0
WireConnection;2;0;1;0
WireConnection;104;0;102;2
WireConnection;104;1;102;1
WireConnection;105;0;103;0
WireConnection;78;0;77;0
WireConnection;146;0;144;0
WireConnection;146;1;145;0
WireConnection;147;0;146;0
WireConnection;79;1;78;0
WireConnection;215;0;197;1
WireConnection;215;1;216;0
WireConnection;67;1;56;0
WireConnection;106;0;105;1
WireConnection;106;1;104;0
WireConnection;7;0;2;0
WireConnection;7;1;26;0
WireConnection;213;0;197;0
WireConnection;213;1;214;0
WireConnection;150;0;173;0
WireConnection;150;1;149;0
WireConnection;209;0;213;0
WireConnection;209;1;215;0
WireConnection;30;0;1;0
WireConnection;29;0;7;0
WireConnection;152;0;147;0
WireConnection;152;1;150;0
WireConnection;80;0;79;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;50;0;44;0
WireConnection;50;1;51;0
WireConnection;112;0;110;0
WireConnection;112;1;113;0
WireConnection;151;0;147;0
WireConnection;151;1;173;0
WireConnection;68;0;67;0
WireConnection;111;0;112;0
WireConnection;153;0;152;0
WireConnection;153;1;151;0
WireConnection;95;0;107;0
WireConnection;70;0;68;1
WireConnection;81;0;80;1
WireConnection;239;0;168;0
WireConnection;200;1;209;0
WireConnection;52;0;50;0
WireConnection;154;0;153;0
WireConnection;154;1;155;0
WireConnection;47;0;52;0
WireConnection;47;1;239;0
WireConnection;118;0;111;0
WireConnection;118;1;172;0
WireConnection;71;0;70;0
WireConnection;71;1;169;0
WireConnection;83;0;81;0
WireConnection;83;1;170;0
WireConnection;203;0;200;0
WireConnection;203;1;201;0
WireConnection;158;0;156;0
WireConnection;158;1;157;0
WireConnection;158;2;151;0
WireConnection;97;0;95;0
WireConnection;97;1;171;0
WireConnection;42;0;39;2
WireConnection;42;1;167;0
WireConnection;38;0;40;0
WireConnection;38;1;41;0
WireConnection;38;2;42;0
WireConnection;49;0;48;0
WireConnection;49;1;46;0
WireConnection;49;2;47;0
WireConnection;34;0;31;0
WireConnection;34;1;32;0
WireConnection;34;2;33;1
WireConnection;91;0;89;0
WireConnection;91;1;90;0
WireConnection;91;2;97;0
WireConnection;116;0;114;0
WireConnection;116;1;115;0
WireConnection;116;2;118;0
WireConnection;62;0;60;0
WireConnection;62;1;61;0
WireConnection;62;2;71;0
WireConnection;206;0;205;0
WireConnection;206;1;204;0
WireConnection;206;2;203;0
WireConnection;86;0;85;0
WireConnection;86;1;84;0
WireConnection;86;2;83;0
WireConnection;159;0;158;0
WireConnection;159;1;154;0
WireConnection;181;0;91;0
WireConnection;177;0;38;0
WireConnection;218;0;206;0
WireConnection;180;0;86;0
WireConnection;178;0;49;0
WireConnection;179;0;62;0
WireConnection;183;0;159;0
WireConnection;182;0;116;0
WireConnection;176;0;34;0
WireConnection;174;1;175;0
WireConnection;174;0;184;0
WireConnection;174;2;185;0
WireConnection;174;3;186;0
WireConnection;174;4;187;0
WireConnection;174;5;188;0
WireConnection;174;6;189;0
WireConnection;174;7;190;0
WireConnection;174;8;191;0
WireConnection;0;0;174;0
ASEEND*/
//CHKSM=BE056ECAC43454E3F77AD6F54EAB63620865FD4E