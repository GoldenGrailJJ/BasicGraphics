// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/PostFX/Scan_ASE"
{
	Properties
	{
		[HideInInspector]_MainTex("_MainTex", 2D) = "white" {}
		[Toggle(_SCANDISTANCEDEBUG_ON)] _ScanDistanceDebug("ScanDistanceDebug", Float) = 0
		_ScaneDistanceDebug("ScaneDistanceDebug", Float) = 0
		[HDR]_ScanColor("ScanColor", Color) = (0,0.706665,1,0)
		_ScanFadeDebug("ScanFadeDebug", Range( 0 , 1)) = 0
		_FadeLineColor("FadeLineColor", Color) = (0.3773585,0.3773585,0.3773585,0)
		_FadeDotColor("FadeDotColor", Color) = (0.3773585,0.3773585,0.3773585,0)
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
			#pragma shader_feature_local _SCANDISTANCEDEBUG_ON


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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float4 _FadeDotColor;
			uniform float4 _FadeLineColor;
			uniform float _ScanDistance;
			uniform float _ScaneDistanceDebug;
			uniform float4 _ScanColor;
			uniform float _ScanFade;
			uniform float _ScanFadeDebug;
					float2 voronoihash150( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi150( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash150( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			
			float3 InvertDepthDir72_g1( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
				return result;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
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
				float4 SceneColor126 = tex2D( _MainTex, uv_MainTex );
				float luminance134 = Luminance(SceneColor126.rgb);
				float4 temp_cast_1 = (luminance134).xxxx;
				float time150 = _Time.y;
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV22_g3 = ase_screenPosNorm.xy;
				float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
				float2 break64_g1 = localUnStereo22_g3;
				float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
				#else
				float staticSwitch38_g1 = clampDepth69_g1;
				#endif
				float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
				float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
				float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
				float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
				float3 In72_g1 = temp_output_46_0_g1;
				float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
				float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
				float4 temp_output_221_0 = mul( unity_CameraToWorld, appendResult49_g1 );
				float4 SceneWorldPosition144 = temp_output_221_0;
				float2 coords150 = (SceneWorldPosition144).xz * 1.0;
				float2 id150 = 0;
				float2 uv150 = 0;
				float voroi150 = voronoi150( coords150, time150, id150, uv150, 0 );
				float4 lerpResult156 = lerp( temp_cast_1 , ( 1.0 - SceneColor126 ) , ( voroi150 * 0.2 ));
				float4 Noise206 = lerpResult156;
				float temp_output_105_0 = length( ( temp_output_221_0 - float4( _WorldSpaceCameraPos , 0.0 ) ) );
				float WorldDistanceToCamera148 = temp_output_105_0;
				float DistanceFade197 = ( 1.0 - saturate( ( WorldDistanceToCamera148 / 10.0 ) ) );
				float4 Dot200 = ( ( pow( ( 1.0 - distance( frac( (SceneWorldPosition144).xz ) , float2( 0.5,0.5 ) ) ) , 100.0 ) * 1.0 ) * _FadeDotColor * DistanceFade197 );
				float2 temp_cast_4 = (0.98).xx;
				float2 break174 = step( temp_cast_4 , frac( (SceneWorldPosition144).xz ) );
				float4 Line201 = ( max( break174.x , break174.y ) * _FadeLineColor * DistanceFade197 );
				#ifdef _SCANDISTANCEDEBUG_ON
				float staticSwitch215 = _ScaneDistanceDebug;
				#else
				float staticSwitch215 = _ScanDistance;
				#endif
				float temp_output_108_0 = saturate( ( temp_output_105_0 / staticSwitch215 ) );
				float FadeSceneMask208 = step( temp_output_108_0 , 0.9 );
				float4 lerpResult132 = lerp( SceneColor126 , ( Noise206 + Dot200 + Line201 ) , FadeSceneMask208);
				float4 FinalSceneColor135 = lerpResult132;
				float ScanLineMask210 = pow( ( 1.0 - distance( temp_output_108_0 , 0.9 ) ) , 50.0 );
				float4 lerpResult128 = lerp( FinalSceneColor135 , _ScanColor , ScanLineMask210);
				#ifdef _SCANDISTANCEDEBUG_ON
				float staticSwitch218 = _ScanFadeDebug;
				#else
				float staticSwitch218 = _ScanFade;
				#endif
				float4 lerpResult191 = lerp( lerpResult128 , SceneColor126 , staticSwitch218);
				
				
				finalColor = lerpResult191;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
104.5714;405.7143;1687.429;783.5715;2458.356;-1220.908;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;212;-2271.307,1123.089;Inherit;False;2015.56;567.5715;扫描线 ScanLineMask;19;103;104;105;144;148;106;108;117;119;122;118;130;208;121;210;215;216;217;221;扫描线 ScanLineMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;221;-2232.307,1214.09;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;103;-2130.306,1318.09;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-1756.308,1290.09;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LengthOpNode;105;-1584.308,1293.09;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;196;-1888.794,2733.578;Inherit;False;1610.164;582.2798;绿线条 LinePattern;11;176;199;187;171;175;174;170;169;168;167;201;绿线条 LinePattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;188;-1424.664,3354.169;Inherit;False;1137.821;357.8899;距离衰减 DistanceFade;6;197;183;182;180;177;181;距离衰减 DistanceFade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;195;-2024.832,2250.924;Inherit;False;1743.07;466.7976;红点 Dot;13;200;184;163;198;161;189;158;157;162;166;164;160;159;红点 Dot;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-1337.308,1210.089;Inherit;False;WorldDistanceToCamera;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-1766.308,1212.089;Inherit;False;SceneWorldPosition;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-1850.794,2865.063;Inherit;False;144;SceneWorldPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-1957.061,2295.959;Inherit;False;144;SceneWorldPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-1214.699,3505.774;Inherit;False;Constant;_Float6;Float 6;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-1336.664,3437.169;Inherit;False;148;WorldDistanceToCamera;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;168;-1594.264,2865.586;Inherit;False;True;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;205;-1877.816,1734.609;Inherit;False;1600.181;457.996;噪音 Voronoi Noise;11;155;134;133;153;150;154;152;137;145;194;206;噪音 Voronoi Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;180;-1003.698,3438.774;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;158;-1709.366,2292.4;Inherit;False;True;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;161;-1497.025,2371.924;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;159;-1443.713,2298.179;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-1386.059,2795.578;Inherit;False;Constant;_Float5;Float 5;3;0;Create;True;0;0;0;False;0;False;0.98;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;217;-1884.308,1431.09;Inherit;False;262;165.2858;代码传入参数;1;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1700.764,1969.833;Inherit;False;144;SceneWorldPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FractNode;169;-1357.187,2871.572;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;182;-829.6978,3439.774;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;125;-2569.992,2202.689;Inherit;True;Property;_MainTex;_MainTex;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;137;-1440.069,1967.274;Inherit;False;True;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-2249.991,2201.689;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;160;-1294.713,2299.179;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-1857.873,1611.444;Inherit;False;Property;_ScaneDistanceDebug;ScaneDistanceDebug;2;0;Create;False;0;0;0;False;0;False;0;120.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;152;-1418.899,2046.534;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1843.308,1472.09;Inherit;False;Global;_ScanDistance;_ScanDistance;2;0;Create;True;0;0;0;False;0;False;2;15.05287;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;170;-1176.286,2848.114;Inherit;False;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;183;-675.2708,3443.14;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;150;-1182.579,1975.386;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.StaticSwitch;215;-1599.873,1421.444;Inherit;False;Property;_ScanDistanceDebug;ScanDistanceDebug;1;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-1111.601,2443.613;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-1668.725,1835.699;Inherit;False;126;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;162;-1113.025,2287.924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;174;-1027.204,2839.362;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;164;-1122.025,2355.924;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-1186.734,2105.72;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-508.084,3439.784;Inherit;False;DistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;163;-882.5121,2282.924;Inherit;False;PowerScale;-1;;20;5ba70760a40e0a6499195a0590fd2e74;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;155;-1371.883,1871.735;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-875.943,2576.968;Inherit;False;197;DistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;175;-892.2035,2837.362;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-990.1074,3122.69;Inherit;False;197;DistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-988.7352,2013.721;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;194;-832.5846,1822.535;Inherit;False;236;206.8572;Voronoi 噪音;1;156;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;187;-1001.041,2934.376;Inherit;False;Property;_FadeLineColor;FadeLineColor;5;0;Create;True;0;0;0;False;0;False;0.3773585,0.3773585,0.3773585,0;0,0.5294118,0.02028293,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;189;-894.1713,2397.405;Inherit;False;Property;_FadeDotColor;FadeDotColor;6;0;Create;True;0;0;0;False;0;False;0.3773585,0.3773585,0.3773585,0;1,0.7162272,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;106;-1335.308,1299.09;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LuminanceNode;134;-1375.264,1784.011;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;108;-1182.308,1302.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;156;-784.5846,1875.535;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-1229.308,1562.09;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-703.1355,2836.745;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-663.5172,2293.419;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;-527.0264,1869.611;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-518.6294,2288.542;Inherit;False;Dot;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-538.904,2826.595;Inherit;False;Line;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;130;-941.3073,1557.09;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;106.8745,1615.254;Inherit;False;201;Line;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;111.8745,1546.254;Inherit;False;200;Dot;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-739.3073,1553.09;Inherit;False;FadeSceneMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;117;-1005.308,1301.09;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;118.9774,1468.378;Inherit;False;206;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-836.3074,1391.09;Inherit;False;Constant;_Float4;Float 4;2;0;Create;True;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;165;404.6611,1472.331;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;344.5392,1636.764;Inherit;False;208;FadeSceneMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;383.0052,1346.113;Inherit;False;126;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;119;-845.3074,1301.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;121;-658.3073,1300.09;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;132;636.5977,1357.338;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;879.4976,1353.117;Inherit;False;FinalSceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;214;182.5521,2360.1;Inherit;False;352.2857;165.2856;Scan效果渐出,参数由代码控制;1;192;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-500.0334,1296.602;Inherit;False;ScanLineMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;232.5521,2410.1;Inherit;False;Global;_ScanFade;_ScanFade;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;238.8708,2546.196;Inherit;False;Property;_ScanFadeDebug;ScanFadeDebug;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;257.6912,2060.722;Inherit;False;Property;_ScanColor;ScanColor;3;1;[HDR];Create;True;0;0;0;False;0;False;0,0.706665,1,0;0,0.8415012,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;127;256.7892,1976.077;Inherit;False;135;FinalSceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;239.3512,2253.414;Inherit;False;210;ScanLineMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;523.4037,2149.955;Inherit;False;126;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;218;571.8013,2422.222;Inherit;False;Property;_ScanDistanceDebug;ScanDistanceDebug;1;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Reference;215;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;525.4018,1979.366;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;224;-1970.078,601.5151;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;229;-1159.954,513.5173;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;233;-720.9771,521.8071;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-1249.977,266.8071;Inherit;False;126;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-2773.819,1888.806;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;226;-1566.954,479.5173;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;238;-3032.25,1843.545;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.FunctionNode;222;-2052.38,466.1447;Inherit;False;Reconstruct World Position From Depth;-1;;4;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;239;-3602.494,1809.256;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;244;-2811.819,2128.806;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;191;815.5953,1982.149;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-3551.494,1944.256;Inherit;False;Constant;_Float9;Float 9;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;230;-976.7986,552.7897;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-1568.954,658.5173;Inherit;False;Property;_Float7;Float 7;7;0;Create;True;0;0;0;False;0;False;20;16.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-3283.494,1840.256;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-1180.799,640.7897;Inherit;False;Constant;_Float8;Float 8;8;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LuminanceNode;234;-994.9771,434.8071;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;246;-3353.819,2048.806;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;227;-1334.954,519.5173;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1061.688,1974.988;Float;False;True;-1;2;ASEMaterialInspector;100;1;TA/PostFX/Scan_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;104;0;221;0
WireConnection;104;1;103;0
WireConnection;105;0;104;0
WireConnection;148;0;105;0
WireConnection;144;0;221;0
WireConnection;168;0;167;0
WireConnection;180;0;177;0
WireConnection;180;1;181;0
WireConnection;158;0;157;0
WireConnection;159;0;158;0
WireConnection;169;0;168;0
WireConnection;182;0;180;0
WireConnection;137;0;145;0
WireConnection;126;0;125;0
WireConnection;160;0;159;0
WireConnection;160;1;161;0
WireConnection;170;0;171;0
WireConnection;170;1;169;0
WireConnection;183;0;182;0
WireConnection;150;0;137;0
WireConnection;150;1;152;0
WireConnection;215;1;107;0
WireConnection;215;0;216;0
WireConnection;162;0;160;0
WireConnection;174;0;170;0
WireConnection;197;0;183;0
WireConnection;163;1;162;0
WireConnection;163;2;164;0
WireConnection;163;3;166;0
WireConnection;155;0;133;0
WireConnection;175;0;174;0
WireConnection;175;1;174;1
WireConnection;153;0;150;0
WireConnection;153;1;154;0
WireConnection;106;0;105;0
WireConnection;106;1;215;0
WireConnection;134;0;133;0
WireConnection;108;0;106;0
WireConnection;156;0;134;0
WireConnection;156;1;155;0
WireConnection;156;2;153;0
WireConnection;176;0;175;0
WireConnection;176;1;187;0
WireConnection;176;2;199;0
WireConnection;184;0;163;0
WireConnection;184;1;189;0
WireConnection;184;2;198;0
WireConnection;206;0;156;0
WireConnection;200;0;184;0
WireConnection;201;0;176;0
WireConnection;130;0;108;0
WireConnection;130;1;118;0
WireConnection;208;0;130;0
WireConnection;117;0;108;0
WireConnection;117;1;118;0
WireConnection;165;0;207;0
WireConnection;165;1;202;0
WireConnection;165;2;203;0
WireConnection;119;0;117;0
WireConnection;121;0;119;0
WireConnection;121;1;122;0
WireConnection;132;0;204;0
WireConnection;132;1;165;0
WireConnection;132;2;209;0
WireConnection;135;0;132;0
WireConnection;210;0;121;0
WireConnection;218;1;192;0
WireConnection;218;0;219;0
WireConnection;128;0;127;0
WireConnection;128;1;129;0
WireConnection;128;2;211;0
WireConnection;229;0;227;0
WireConnection;233;0;232;0
WireConnection;233;1;234;0
WireConnection;233;2;230;0
WireConnection;243;0;238;1
WireConnection;226;0;222;0
WireConnection;226;1;224;0
WireConnection;238;0;240;0
WireConnection;238;1;246;0
WireConnection;244;0;238;2
WireConnection;191;0;128;0
WireConnection;191;1;193;0
WireConnection;191;2;218;0
WireConnection;230;0;229;0
WireConnection;230;1;231;0
WireConnection;240;0;239;0
WireConnection;240;1;241;0
WireConnection;234;0;232;0
WireConnection;227;0;226;0
WireConnection;227;1;228;0
WireConnection;0;0;191;0
ASEEND*/
//CHKSM=B7F9B0A93DE752B8CB8AC0BBAB911D8CF1962F53