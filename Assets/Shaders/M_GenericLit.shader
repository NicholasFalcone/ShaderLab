Shader "Mixedbag/GenericLitShader"
{
	Properties
	{
		[NoScaleOffset] _BaseMap("Albedo", 2D) = "white" {}
		_BaseColor("Color", Color) = (0.5, 0.5, 0.5, 0)
		[Normal][NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
		_NormalStrenght("NormalStrenght", Float) = 1
		[NoScaleOffset]_MetallicGlossMap("MetallicSmoothness", 2D) = "white" {}
		_Metalilc("Metalilc", Range(0, 1)) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 0
		[NoScaleOffset]_Emissive("Emissive", 2D) = "white" {}
		[HDR]_EmissiveColor("EmissiveColor", Color) = (0, 0, 0, 0)
		_Tiling("Tiling", Vector) = (1, 1, 0, 0)
		_Offset("Offset", Vector) = (0, 0, 0, 0)
		_TilingNormalMap("Tiling Normal Map", Vector) = (1, 1, 0, 0)
		_OffsetNormalMap("Offset Normal Map", Vector) = (0, 0, 0, 0)
		[HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 1
		[HideInInspector]_CastShadows("_CastShadows", Float) = 1
		[HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 1
		[HideInInspector]_Surface("_Surface", Float) = 0
		[HideInInspector]_Blend("_Blend", Float) = 0
		[HideInInspector]_AlphaClip("_AlphaClip", Float) = 0
		[HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
		[HideInInspector]_DstBlend("_DstBlend", Float) = 0
		[HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
		[HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
		[HideInInspector]_ZTest("_ZTest", Float) = 4
		[HideInInspector]_Cull("_Cull", Float) = 2
		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
		[HideInInspector]_QueueControl("_QueueControl", Float) = -1
		[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}
	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Opaque"
			"UniversalMaterialType" = "Lit"
			"Queue" = "Geometry"
		}
		Pass
		{
			Name "Universal Forward"
			Tags
			{
				"LightMode" = "UniversalForward"
			}

			// Render State
			Cull[_Cull]
			Blend[_SrcBlend][_DstBlend]
			ZTest[_ZTest]
			ZWrite[_ZWrite]

			HLSLPROGRAM

			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma shader_feature _ DOTS_INSTANCING_ON
			#pragma vertex vert
			#pragma fragment frag

			// Keywords
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma shader_feature _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma shader_feature _ LIGHTMAP_SHADOW_MIXING
			#pragma shader_feature _ SHADOWS_SHADOWMASK

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _CLUSTERED_RENDERING
			#pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
			#pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ _SPECULAR_SETUP
			#pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF

			// Defines
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define VARYINGS_NEED_POSITION_WS
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define VARYINGS_NEED_VIEWDIRECTION_WS
			#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
			#define VARYINGS_NEED_SHADOW_COORD
			#define VARYINGS_NEED_CULLFACE
			#define FEATURES_GRAPH_VERTEX
			#define SHADERPASS SHADERPASS_FORWARD
			#define _FOG_FRAGMENT 1

			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS;
				float3 normalWS;
				float4 tangentWS;
				float4 texCoord0;
				float3 viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					float2 staticLightmapUV;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					float3 sh;
				#endif
				float4 fogFactorAndVertexLight;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
				float4 uv0;
				float FaceSign;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float3 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				float4 interp3 : INTERP3;
				float3 interp4 : INTERP4;
				float2 interp5 : INTERP5;
				float2 interp6 : INTERP6;
				float3 interp7 : INTERP7;
				float4 interp8 : INTERP8;
				float4 interp9 : INTERP9;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};

			PackedVaryings PackVaryings(Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz = input.positionWS;
				output.interp1.xyz = input.normalWS;
				output.interp2.xyzw = input.tangentWS;
				output.interp3.xyzw = input.texCoord0;
				output.interp4.xyz = input.viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					output.interp5.xy = input.staticLightmapUV;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.interp6.xy = input.dynamicLightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.interp7.xyz = input.sh;
				#endif
				output.interp8.xyzw = input.fogFactorAndVertexLight;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.interp9.xyzw = input.shadowCoord;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}

			Varyings UnpackVaryings(PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.positionWS = input.interp0.xyz;
				output.normalWS = input.interp1.xyz;
				output.tangentWS = input.interp2.xyzw;
				output.texCoord0 = input.interp3.xyzw;
				output.viewDirectionWS = input.interp4.xyz;
				#if defined(LIGHTMAP_ON)
					output.staticLightmapUV = input.interp5.xy;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV = input.interp6.xy;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.sh = input.interp7.xyz;
				#endif
				output.fogFactorAndVertexLight = input.interp8.xyzw;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.shadowCoord = input.interp9.xyzw;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}

			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
				float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END

			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);

			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};

			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}

			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif

			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float3 NormalTS;
				float3 Emission;
				float Metallic;
				float3 Specular;
				float Smoothness;
				float Occlusion;
				float Alpha;
				float AlphaClipThreshold;
			};

			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				/// Caluclate TilingAndOffset
				float2 _TilingAndOffset = IN.uv0.xy * _Tiling + _Offset;
				/// Caluclate Normal and Additional TilingAndOffset
				float2 _TilingAndOffsetNormalMap = IN.uv0.xy * _TilingNormalMap + _OffsetNormalMap;
				/// Base Color
				UnityTexture2D TextureNoSale = UnityBuildTexture2DStructNoScale(_BaseMap);
				float4 _SampleTexture2D = SAMPLE_TEXTURE2D(TextureNoSale.tex, TextureNoSale.samplerstate, TextureNoSale.GetTransformedUV(_TilingAndOffset));
				float _SampleTextureAlpha = _SampleTexture2D.a;
				float4 _baseMapResult = _BaseColor * _SampleTexture2D;
				
				///Normal
				UnityTexture2D _BuildTexture = UnityBuildTexture2DStructNoScale(_BumpMap);
				float4 _SampleTexture2dRGBA = SAMPLE_TEXTURE2D(_BuildTexture.tex, _BuildTexture.samplerstate, _BuildTexture.GetTransformedUV(_TilingAndOffsetNormalMap));
				_SampleTexture2dRGBA.rgb = UnpackNormal(_SampleTexture2dRGBA);
				float3 _NormalStrengthInterpolated =   float3((_SampleTexture2dRGBA.xyz).rg * _NormalStrenght, lerp(1, (_SampleTexture2dRGBA.xyz).b, saturate(_NormalStrenght)));
				///Emissive
				UnityTexture2D _EmissiveTexture2D = UnityBuildTexture2DStructNoScale(_Emissive);
				float4 _SampleTexture2DEmissinve = SAMPLE_TEXTURE2D(_EmissiveTexture2D.tex, _EmissiveTexture2D.samplerstate, _EmissiveTexture2D.GetTransformedUV(_TilingAndOffsetNormalMap));
				float4 _EmissiveRGBA = IsGammaSpace() ? LinearToSRGB(_EmissiveColor) : _EmissiveColor;
				float4 _EmissinveResult = _SampleTexture2DEmissinve *_EmissiveRGBA;
				UnityTexture2D _MetallicGlossTextureScale = UnityBuildTexture2DStructNoScale(_MetallicGlossMap);

				///Metalic
				float4 _SampleTexture2DMetalicGloss = SAMPLE_TEXTURE2D(_MetallicGlossTextureScale.tex, _MetallicGlossTextureScale.samplerstate, _MetallicGlossTextureScale.GetTransformedUV(_TilingAndOffsetNormalMap));
				float _MetalicResult = (_SampleTexture2DMetalicGloss.r * _Metalilc);

				float _IsFrontFace = max(0, IN.FaceSign.x);
				float _SmoothnessResult = (_SampleTexture2DMetalicGloss.a * _Smoothness) * ( _IsFrontFace ? 1 : -1);

				/// Calculate Alpha				
				float _AlphaResult = _SampleTextureAlpha * _BaseColor.w;
				
				/// Assigne values
				surface.BaseColor = (_baseMapResult.xyz);
				surface.NormalTS = _NormalStrengthInterpolated;
				surface.Emission = (_EmissinveResult.xyz);
				surface.Metallic = _MetalicResult;
				surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
				surface.Smoothness = _SmoothnessResult;
				surface.Occlusion = 1;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}

			// --------------------------------------------------
			// Build Graph Inputs
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				output.ObjectSpaceNormal = input.normalOS;
				output.ObjectSpaceTangent = input.tangentOS.xyz;
				output.ObjectSpacePosition = input.positionOS;
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

				output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

				return output;
			}
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "GBuffer"
			Tags
			{
				"LightMode" = "UniversalGBuffer"
			}
			
			// Render State
			Cull [_Cull]
			Blend [_SrcBlend] [_DstBlend]
			ZTest [_ZTest]
			ZWrite [_ZWrite]
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma vertex vert
			#pragma fragment frag
			
			// Keywords
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
			#pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ _SPECULAR_SETUP
			#pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define VARYINGS_NEED_POSITION_WS
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define VARYINGS_NEED_VIEWDIRECTION_WS
			#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
			#define VARYINGS_NEED_SHADOW_COORD
			#define VARYINGS_NEED_CULLFACE
			#define FEATURES_GRAPH_VERTEX
			#define SHADERPASS SHADERPASS_GBUFFER
			#define _FOG_FRAGMENT 1
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS;
				float3 normalWS;
				float4 tangentWS;
				float4 texCoord0;
				float3 viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					float2 staticLightmapUV;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					float3 sh;
				#endif
				float4 fogFactorAndVertexLight;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
				float4 uv0;
				float FaceSign;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float3 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				float4 interp3 : INTERP3;
				float3 interp4 : INTERP4;
				float2 interp5 : INTERP5;
				float2 interp6 : INTERP6;
				float3 interp7 : INTERP7;
				float4 interp8 : INTERP8;
				float4 interp9 : INTERP9;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz =  input.positionWS;
				output.interp1.xyz =  input.normalWS;
				output.interp2.xyzw =  input.tangentWS;
				output.interp3.xyzw =  input.texCoord0;
				output.interp4.xyz =  input.viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					output.interp5.xy =  input.staticLightmapUV;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.interp6.xy =  input.dynamicLightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.interp7.xyz =  input.sh;
				#endif
				output.interp8.xyzw =  input.fogFactorAndVertexLight;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.interp9.xyzw =  input.shadowCoord;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.positionWS = input.interp0.xyz;
				output.normalWS = input.interp1.xyz;
				output.tangentWS = input.interp2.xyzw;
				output.texCoord0 = input.interp3.xyzw;
				output.viewDirectionWS = input.interp4.xyz;
				#if defined(LIGHTMAP_ON)
					output.staticLightmapUV = input.interp5.xy;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV = input.interp6.xy;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.sh = input.interp7.xyz;
				#endif
				output.fogFactorAndVertexLight = input.interp8.xyzw;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.shadowCoord = input.interp9.xyzw;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}

			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
				float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
		
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float3 NormalTS;
				float3 Emission;
				float Metallic;
				float3 Specular;
				float Smoothness;
				float Occlusion;
				float Alpha;
				float AlphaClipThreshold;
			};

			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;

				/// Caluclate Normal and Additional TilingAndOffset
				float2 _TilingAndOffsetNormalMap = IN.uv0.xy * _TilingNormalMap + _OffsetNormalMap;

				// Base
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float4 _BaseColorResult = _BaseColor * _BaseSampleTexture;
				
				// Normal
				UnityTexture2D _NormalTexture2D = UnityBuildTexture2DStructNoScale(_BumpMap);
				float4 _NormalSampleTexture2D = SAMPLE_TEXTURE2D(_NormalTexture2D.tex, _NormalTexture2D.samplerstate, _NormalTexture2D.GetTransformedUV(_TilingAndOffsetNormalMap));
				_NormalSampleTexture2D.rgb = UnpackNormal(_NormalSampleTexture2D);
				float3 _NormalStrengthTexture = float3((_NormalSampleTexture2D.xyz).rg * _NormalStrenght, lerp(1, (_NormalSampleTexture2D.xyz).b, saturate(_NormalStrenght)));

				// Emissive
				UnityTexture2D _EmissiveTexture = UnityBuildTexture2DStructNoScale(_Emissive);
				float4 _EmissiveSampleTexture = SAMPLE_TEXTURE2D(_EmissiveTexture.tex, _EmissiveTexture.samplerstate, _EmissiveTexture.GetTransformedUV(_TilingAndOffsetNormalMap));
				float4 _EmissiveColorResult = IsGammaSpace() ? LinearToSRGB(_EmissiveColor) : _EmissiveColor;
				float4 _EmissiveResult = _EmissiveSampleTexture *_EmissiveColorResult;
				
				// Metallic
				UnityTexture2D _MetallicTexture2D = UnityBuildTexture2DStructNoScale(_MetallicGlossMap);
				float4 _MetallicSampleTexture = SAMPLE_TEXTURE2D(_MetallicTexture2D.tex, _MetallicTexture2D.samplerstate, _MetallicTexture2D.GetTransformedUV(_TilingAndOffsetNormalMap));
				float2 _Vector2_1cbdf5bb0cbe4227b42230f54aa56559_Out_0 = float2(0, _Metalilc);
				float _MetalilcResult = (_MetallicSampleTexture.r) * _Metalilc;
				float _IsFrontFace = max(0, IN.FaceSign.x);
				float _RemapAlpha = (_MetallicSampleTexture.a * _Smoothness);
				float _RemapAlphaInvers = _RemapAlpha * -1;
				float _SmoothnessResult = _IsFrontFace ? _RemapAlpha : _RemapAlphaInvers;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				
				surface.BaseColor = (_BaseColorResult.xyz);
				surface.NormalTS = _NormalStrengthTexture;
				surface.Emission = (_EmissiveResult.xyz);
				surface.Metallic = _MetalilcResult;
				surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
				surface.Smoothness = _SmoothnessResult;
				surface.Occlusion = 1;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
		
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal = input.normalOS;
				output.ObjectSpaceTangent = input.tangentOS.xyz;
				output.ObjectSpacePosition = input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
				
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "ShadowCaster"
			Tags
			{
				"LightMode" = "ShadowCaster"
			}
			
			// Render State
			Cull [_Cull]
			ZTest LEqual
			ZWrite On
			ColorMask 0
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma vertex vert
			#pragma fragment frag
			
			// Keywords
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON

			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			#define SHADERPASS SHADERPASS_SHADOWCASTER

			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float4 interp1 : INTERP1;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz =  input.normalWS;
				output.interp1.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.normalWS = input.interp0.xyz;
				output.texCoord0 = input.interp1.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
				float4 _BaseColor;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "DepthOnly"
			Tags
			{
				"LightMode" = "DepthOnly"
			}
			
			// Render State
			Cull [_Cull]
			ZTest LEqual
			ZWrite On
			ColorMask 0
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma vertex vert
			#pragma fragment frag
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			
			// Defines
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHONLY
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "DepthNormals"
			Tags
			{
				"LightMode" = "DepthNormals"
			}
			
			// Render State
			Cull [_Cull]
			ZTest LEqual
			ZWrite On
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHNORMALS
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS;
				float4 tangentWS;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float4 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz =  input.normalWS;
				output.interp1.xyzw =  input.tangentWS;
				output.interp2.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.normalWS = input.interp0.xyz;
				output.tangentWS = input.interp1.xyzw;
				output.texCoord0 = input.interp2.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
			{
				Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 NormalTS;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _NormalTexture2D = UnityBuildTexture2DStructNoScale(_BumpMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				/// Caluclate Normal and Additional TilingAndOffset
				float2 _TilingAndOffsetNormalMap = IN.uv0.xy * _TilingNormalMap + _OffsetNormalMap;

				float4 _NormalSampleTexture2D = SAMPLE_TEXTURE2D(_NormalTexture2D.tex, _NormalTexture2D.samplerstate, _NormalTexture2D.GetTransformedUV(_TilingAndOffsetNormalMap));
				_NormalSampleTexture2D.rgb = UnpackNormal(_NormalSampleTexture2D);
				float3 _NormalStrengthTexture;
				Unity_NormalStrength_float((_NormalSampleTexture2D.xyz), _NormalStrenght, _NormalStrengthTexture);
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _Swizzle_264def1e07cf4f74bb2cd6ee9b43c608_Out_1 = _BaseColor.w;
				float _AlphaResult =  _BaseSampleTexture.a * _BaseColor.w;
				surface.NormalTS = _NormalStrengthTexture;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "Meta"
			Tags
			{
				"LightMode" = "Meta"
			}
			
			// Render State
			Cull Off
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature _ EDITOR_VISUALIZATION
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define VARYINGS_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD1
			#define VARYINGS_NEED_TEXCOORD2
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_META
			#define _FOG_FRAGMENT 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				float4 texCoord1;
				float4 texCoord2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				float4 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				output.interp1.xyzw =  input.texCoord1;
				output.interp2.xyzw =  input.texCoord2;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				output.texCoord1 = input.interp1.xyzw;
				output.texCoord2 = input.interp2.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
			{
				Out = A * B;
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float3 Emission;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _Property_e5953c722a114afa8b87e4545f686667_Out_0 = _Tiling;
				float2 _Property_f199008f905943d9a6bd372e37d204ee_Out_0 = _Offset;
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				/// Caluclate Normal and Additional TilingAndOffset
				float2 _TilingAndOffsetNormalMap = IN.uv0.xy * _TilingNormalMap + _OffsetNormalMap;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float4 _BaseColorResult;
				Unity_Multiply_float4_float4(_BaseColor, _BaseSampleTexture, _BaseColorResult);
				UnityTexture2D _EmissiveTexture = UnityBuildTexture2DStructNoScale(_Emissive);
				float4 _EmissiveSampleTexture = SAMPLE_TEXTURE2D(_EmissiveTexture.tex, _EmissiveTexture.samplerstate, _EmissiveTexture.GetTransformedUV(_TilingAndOffsetNormalMap));
				float4 _EmissiveColorResult = IsGammaSpace() ? LinearToSRGB(_EmissiveColor) : _EmissiveColor;
				float4 _EmissiveResult = _EmissiveSampleTexture *_EmissiveColorResult;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.BaseColor = (_BaseColorResult.xyz);
				surface.Emission = (_EmissiveResult.xyz);
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "SceneSelectionPass"
			Tags
			{
				"LightMode" = "SceneSelectionPass"
			}
			
			// Render State
			Cull Off
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENESELECTIONPASS 1
			#define ALPHA_CLIP_THRESHOLD 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "ScenePickingPass"
			Tags
			{
				"LightMode" = "Picking"
			}
			
			// Render State
			Cull [_Cull]
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1
			#define ALPHA_CLIP_THRESHOLD 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			// Name: <None>
			Tags
			{
				"LightMode" = "Universal2D"
			}
			
			// Render State
			Cull [_Cull]
			Blend [_SrcBlend] [_DstBlend]
			ZTest [_ZTest]
			ZWrite [_ZWrite]
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_2D
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
			{
				Out = A * B;
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float4 _BaseColorResult = _BaseColor * _BaseSampleTexture;
				float _AlphaResult = _BaseSampleTexture.a * +_BaseColor.w;
				surface.BaseColor = (_BaseColorResult.xyz);
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
			
			ENDHLSL
		}
	}
	SubShader
	{
		Tags
		{
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"UniversalMaterialType" = "Lit"
			"Queue"="Geometry"
			"ShaderGraphShader"="true"
			"ShaderGraphTargetId"="UniversalLitSubTarget"
		}
		Pass
		{
			Name "Universal Forward"
			Tags
			{
				"LightMode" = "UniversalForward"
			}
			
			// Render State
			Cull [_Cull]
			Blend [_SrcBlend] [_DstBlend]
			ZTest [_ZTest]
			ZWrite [_ZWrite]
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _CLUSTERED_RENDERING
			#pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
			#pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ _SPECULAR_SETUP
			#pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define VARYINGS_NEED_POSITION_WS
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define VARYINGS_NEED_VIEWDIRECTION_WS
			#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
			#define VARYINGS_NEED_SHADOW_COORD
			#define VARYINGS_NEED_CULLFACE
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_FORWARD
			#define _FOG_FRAGMENT 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS;
				float3 normalWS;
				float4 tangentWS;
				float4 texCoord0;
				float3 viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					float2 staticLightmapUV;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					float3 sh;
				#endif
				float4 fogFactorAndVertexLight;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
				float4 uv0;
				float FaceSign;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float3 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				float4 interp3 : INTERP3;
				float3 interp4 : INTERP4;
				float2 interp5 : INTERP5;
				float2 interp6 : INTERP6;
				float3 interp7 : INTERP7;
				float4 interp8 : INTERP8;
				float4 interp9 : INTERP9;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz =  input.positionWS;
				output.interp1.xyz =  input.normalWS;
				output.interp2.xyzw =  input.tangentWS;
				output.interp3.xyzw =  input.texCoord0;
				output.interp4.xyz =  input.viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					output.interp5.xy =  input.staticLightmapUV;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.interp6.xy =  input.dynamicLightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.interp7.xyz =  input.sh;
				#endif
				output.interp8.xyzw =  input.fogFactorAndVertexLight;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.interp9.xyzw =  input.shadowCoord;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.positionWS = input.interp0.xyz;
				output.normalWS = input.interp1.xyz;
				output.tangentWS = input.interp2.xyzw;
				output.texCoord0 = input.interp3.xyzw;
				output.viewDirectionWS = input.interp4.xyz;
				#if defined(LIGHTMAP_ON)
					output.staticLightmapUV = input.interp5.xy;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV = input.interp6.xy;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.sh = input.interp7.xyz;
				#endif
				output.fogFactorAndVertexLight = input.interp8.xyzw;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					output.shadowCoord = input.interp9.xyzw;
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
			{
				Out = A * B;
			}
			
			void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
			{
				Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
			}
			
			void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
			{
				Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			void Unity_Branch_float(float Predicate, float True, float False, out float Out)
			{
				Out = Predicate ? True : False;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float3 NormalTS;
				float3 Emission;
				float Metallic;
				float3 Specular;
				float Smoothness;
				float Occlusion;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;

				float2 _TilingResultNormalMap = IN.uv0.xy * _TilingNormalMap + _OffsetNormalMap;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));

				float4 _BaseColorResult = _BaseColor * _BaseSampleTexture;
				UnityTexture2D _NormalTexture2D = UnityBuildTexture2DStructNoScale(_BumpMap);
				float4 _NormalSampleTexture2D = SAMPLE_TEXTURE2D(_NormalTexture2D.tex, _NormalTexture2D.samplerstate, _NormalTexture2D.GetTransformedUV(_TilingResultNormalMap));
				_NormalSampleTexture2D.rgb = UnpackNormal(_NormalSampleTexture2D);
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_R_4 = _NormalSampleTexture2D.r;
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_G_5 = _NormalSampleTexture2D.g;
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_B_6 = _NormalSampleTexture2D.b;
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_A_7 = _NormalSampleTexture2D.a;
				float3 _NormalStrengthTexture;
				Unity_NormalStrength_float((_NormalSampleTexture2D.xyz), _NormalStrenght, _NormalStrengthTexture);
				UnityTexture2D _EmissiveTexture = UnityBuildTexture2DStructNoScale(_Emissive);
				float4 _EmissiveSampleTexture = SAMPLE_TEXTURE2D(_EmissiveTexture.tex, _EmissiveTexture.samplerstate, _EmissiveTexture.GetTransformedUV(_TilingResultNormalMap));
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_R_4 = _EmissiveSampleTexture.r;
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_G_5 = _EmissiveSampleTexture.g;
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_B_6 = _EmissiveSampleTexture.b;
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_A_7 = _EmissiveSampleTexture.a;
				float4 _EmissiveColorResult = IsGammaSpace() ? LinearToSRGB(_EmissiveColor) : _EmissiveColor;
				float4 _EmissiveResult;
				Unity_Multiply_float4_float4(_EmissiveSampleTexture, _EmissiveColorResult, _EmissiveResult);
				UnityTexture2D _MetallicTexture2D = UnityBuildTexture2DStructNoScale(_MetallicGlossMap);
				float4 _MetallicSampleTexture = SAMPLE_TEXTURE2D(_MetallicTexture2D.tex, _MetallicTexture2D.samplerstate, _MetallicTexture2D.GetTransformedUV(_TilingResultNormalMap));
				float _SampleTexture2D_c80ebcd3ed234485a5641dd06cac11da_R_4 = _MetallicSampleTexture.r;
				float _SampleTexture2D_c80ebcd3ed234485a5641dd06cac11da_G_5 = _MetallicSampleTexture.g;
				float _SampleTexture2D_c80ebcd3ed234485a5641dd06cac11da_B_6 = _MetallicSampleTexture.b;
				float _SampleTexture2D_c80ebcd3ed234485a5641dd06cac11da_A_7 = _MetallicSampleTexture.a;
				float2 _Vector2_1cbdf5bb0cbe4227b42230f54aa56559_Out_0 = float2(0, _Metalilc);
				float _MetalilcResult;
				Unity_Remap_float(_SampleTexture2D_c80ebcd3ed234485a5641dd06cac11da_R_4, float2 (0, 1), _Vector2_1cbdf5bb0cbe4227b42230f54aa56559_Out_0, _MetalilcResult);
				float _IsFrontFace = max(0, IN.FaceSign.x);
				float2 _Vector2_69d0cd255de44ab58f4b4941b9971485_Out_0 = float2(0, _Smoothness);
				float _RemapAlpha;
				Unity_Remap_float(_SampleTexture2D_c80ebcd3ed234485a5641dd06cac11da_A_7, float2 (0, 1), _Vector2_69d0cd255de44ab58f4b4941b9971485_Out_0, _RemapAlpha);
				float _Multiply_27280115295844c6a9e0e6edadbb2342_Out_2;
				Unity_Multiply_float_float(_RemapAlpha, -1, _Multiply_27280115295844c6a9e0e6edadbb2342_Out_2);
				float _SmoothnessResult;
				Unity_Branch_float(_IsFrontFace, _RemapAlpha, _Multiply_27280115295844c6a9e0e6edadbb2342_Out_2, _SmoothnessResult);
				float _Swizzle_264def1e07cf4f74bb2cd6ee9b43c608_Out_1 = _BaseColor.w;
				float _AlphaResult;
				Unity_Multiply_float_float(_BaseSampleTexture.a, _Swizzle_264def1e07cf4f74bb2cd6ee9b43c608_Out_1, _AlphaResult);
				surface.BaseColor = (_BaseColorResult.xyz);
				surface.NormalTS = _NormalStrengthTexture;
				surface.Emission = (_EmissiveResult.xyz);
				surface.Metallic = _MetalilcResult;
				surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
				surface.Smoothness = _SmoothnessResult;
				surface.Occlusion = 1;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				output.ObjectSpaceNormal = input.normalOS;
				output.ObjectSpaceTangent = input.tangentOS.xyz;
				output.ObjectSpacePosition = input.positionOS;
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "ShadowCaster"
			Tags
			{
				"LightMode" = "ShadowCaster"
			}
			
			// Render State
			Cull [_Cull]
			ZTest LEqual
			ZWrite On
			ColorMask 0
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag

			
			// Keywords
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON

			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			#define SHADERPASS SHADERPASS_SHADOWCASTER

			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
		
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float4 interp1 : INTERP1;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz =  input.normalWS;
				output.interp1.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.normalWS = input.interp0.xyz;
				output.texCoord0 = input.interp1.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "DepthOnly"
			Tags
			{
				"LightMode" = "DepthOnly"
			}
			
			// Render State
			Cull [_Cull]
			ZTest LEqual
			ZWrite On
			ColorMask 0
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHONLY
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "DepthNormals"
			Tags
			{
				"LightMode" = "DepthNormals"
			}
			
			// Render State
			Cull [_Cull]
			ZTest LEqual
			ZWrite On
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHNORMALS
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS;
				float4 tangentWS;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 interp0 : INTERP0;
				float4 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyz =  input.normalWS;
				output.interp1.xyzw =  input.tangentWS;
				output.interp2.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.normalWS = input.interp0.xyz;
				output.tangentWS = input.interp1.xyzw;
				output.texCoord0 = input.interp2.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
			{
				Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 NormalTS;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _NormalTexture2D = UnityBuildTexture2DStructNoScale(_BumpMap);
				float2 _Property_e5953c722a114afa8b87e4545f686667_Out_0 = _Tiling;
				float2 _Property_f199008f905943d9a6bd372e37d204ee_Out_0 = _Offset;
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float2 _TilingResultNormalMap = IN.uv0.xy * _TilingNormalMap + _OffsetNormalMap;
				float4 _NormalSampleTexture2D = SAMPLE_TEXTURE2D(_NormalTexture2D.tex, _NormalTexture2D.samplerstate, _NormalTexture2D.GetTransformedUV(_TilingResultNormalMap));
				_NormalSampleTexture2D.rgb = UnpackNormal(_NormalSampleTexture2D);
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_R_4 = _NormalSampleTexture2D.r;
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_G_5 = _NormalSampleTexture2D.g;
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_B_6 = _NormalSampleTexture2D.b;
				float _SampleTexture2D_10f804ed6d7a444fb145150492ab06b8_A_7 = _NormalSampleTexture2D.a;
				float3 _NormalStrengthTexture;
				Unity_NormalStrength_float((_NormalSampleTexture2D.xyz), _NormalStrenght, _NormalStrengthTexture);
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.NormalTS = _NormalStrengthTexture;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "Meta"
			Tags
			{
				"LightMode" = "Meta"
			}
			
			// Render State
			Cull Off
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature _ EDITOR_VISUALIZATION
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define VARYINGS_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD1
			#define VARYINGS_NEED_TEXCOORD2
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_META
			#define _FOG_FRAGMENT 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				float4 texCoord1;
				float4 texCoord2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				float4 interp1 : INTERP1;
				float4 interp2 : INTERP2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				output.interp1.xyzw =  input.texCoord1;
				output.interp2.xyzw =  input.texCoord2;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				output.texCoord1 = input.interp1.xyzw;
				output.texCoord2 = input.interp2.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
			{
				Out = A * B;
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float3 Emission;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float2 _TilingResultNormalMap = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float4 _BaseColorResult;
				Unity_Multiply_float4_float4(_BaseColor, _BaseSampleTexture, _BaseColorResult);
				UnityTexture2D _EmissiveTexture = UnityBuildTexture2DStructNoScale(_Emissive);
				float4 _EmissiveSampleTexture = SAMPLE_TEXTURE2D(_EmissiveTexture.tex, _EmissiveTexture.samplerstate, _EmissiveTexture.GetTransformedUV(_TilingResultNormalMap));
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_R_4 = _EmissiveSampleTexture.r;
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_G_5 = _EmissiveSampleTexture.g;
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_B_6 = _EmissiveSampleTexture.b;
				float _SampleTexture2D_4d59cbcdafb3443dbf0379853643041e_A_7 = _EmissiveSampleTexture.a;
				float4 _EmissiveColorResult = IsGammaSpace() ? LinearToSRGB(_EmissiveColor) : _EmissiveColor;
				float4 _EmissiveResult;
				Unity_Multiply_float4_float4(_EmissiveSampleTexture, _EmissiveColorResult, _EmissiveResult);
				float _Swizzle_264def1e07cf4f74bb2cd6ee9b43c608_Out_1 = _BaseColor.w;
				float _AlphaResult;
				Unity_Multiply_float_float(_BaseSampleTexture.a, _Swizzle_264def1e07cf4f74bb2cd6ee9b43c608_Out_1, _AlphaResult);
				surface.BaseColor = (_BaseColorResult.xyz);
				surface.Emission = (_EmissiveResult.xyz);
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
		
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "SceneSelectionPass"
			Tags
			{
				"LightMode" = "SceneSelectionPass"
			}
			
			// Render State
			Cull Off
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENESELECTIONPASS 1
			#define ALPHA_CLIP_THRESHOLD 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _Property_e5953c722a114afa8b87e4545f686667_Out_0 = _Tiling;
				float2 _Property_f199008f905943d9a6bd372e37d204ee_Out_0 = _Offset;
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			Name "ScenePickingPass"
			Tags
			{
				"LightMode" = "Picking"
			}
			
			// Render State
			Cull [_Cull]
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			
			// DotsInstancingOptions: <None>
			// HybridV1InjectedBuiltinProperties: <None>
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1
			#define ALPHA_CLIP_THRESHOLD 1
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			
			// custom interpolator pre-include
			/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			// --------------------------------------------------
			// Structs and Packing
			
			// custom interpolators pre packing
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Functions
			
			void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
			{
				Out = UV * Tiling + Offset;
			}
			
			void Unity_Multiply_float_float(float A, float B, out float Out)
			{
				Out = A * B;
			}
			
			// Custom interpolators pre vertex
			/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_R_4 = _BaseSampleTexture.r;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_G_5 = _BaseSampleTexture.g;
				float _SampleTexture2D_abcef5fa5b3949b88595684df2a02893_B_6 = _BaseSampleTexture.b;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
		
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
			
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
			
			ENDHLSL
		}
		Pass
		{
			// Name: <None>
			Tags
			{
				"LightMode" = "Universal2D"
			}
			
			// Render State
			Cull [_Cull]
			Blend [_SrcBlend] [_DstBlend]
			ZTest [_ZTest]
			ZWrite [_ZWrite]
			
			HLSLPROGRAM
			
			// Pragmas
			#pragma target 2.0
			#pragma only_renderers gles gles3 glcore d3d11
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag
			
			// Keywords
			#pragma shader_feature_local_fragment _ _ALPHATEST_ON
			// GraphKeywords: <None>
			
			// Defines
			
			#define _NORMALMAP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD0
			#define FEATURES_GRAPH_VERTEX
			/* WARNING: $splice Could not find named fragment 'PassInstancing' */
			#define SHADERPASS SHADERPASS_2D
			/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			struct SurfaceDescriptionInputs
			{
				float4 uv0;
			};
			struct VertexDescriptionInputs
			{
				float3 ObjectSpaceNormal;
				float3 ObjectSpaceTangent;
				float3 ObjectSpacePosition;
			};
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 interp0 : INTERP0;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			PackedVaryings PackVaryings (Varyings input)
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);
				output.positionCS = input.positionCS;
				output.interp0.xyzw =  input.texCoord0;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			Varyings UnpackVaryings (PackedVaryings input)
			{
				Varyings output;
				output.positionCS = input.positionCS;
				output.texCoord0 = input.interp0.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_TexelSize;
				float4 _BumpMap_TexelSize;
				float4 _MetallicGlossMap_TexelSize;
				float2 _Tiling;
				float2 _Offset;
								float2 _TilingNormalMap;
				float2 _OffsetNormalMap;
				float _Smoothness;
				float4 _BaseColor;
				float _NormalStrenght;
				float _Metalilc;
				float4 _EmissiveColor;
				float4 _Emissive_TexelSize;
			CBUFFER_END
			
			// Object and Global properties
			SAMPLER(SamplerState_Linear_Repeat);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_Emissive);
			SAMPLER(sampler_Emissive);
			
			// Graph Includes
			// GraphIncludes: <None>
			
			// -- Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif
			
			// -- Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif
			
			// Graph Vertex
			struct VertexDescription
			{
				float3 Position;
				float3 Normal;
				float3 Tangent;
			};
			
			VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
			{
				VertexDescription description = (VertexDescription)0;
				description.Position = IN.ObjectSpacePosition;
				description.Normal = IN.ObjectSpaceNormal;
				description.Tangent = IN.ObjectSpaceTangent;
				return description;
			}
			
			// Custom interpolators, pre surface
			#ifdef FEATURES_GRAPH_VERTEX
				Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
				{
					return output;
				}
				#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
			#endif
			
			// Graph Pixel
			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				UnityTexture2D _BaseMapTexture = UnityBuildTexture2DStructNoScale(_BaseMap);
				float2 _TilingResult = IN.uv0.xy * _Tiling + _Offset;
				float4 _BaseSampleTexture = SAMPLE_TEXTURE2D(_BaseMapTexture.tex, _BaseMapTexture.samplerstate, _BaseMapTexture.GetTransformedUV(_TilingResult));
				float4 _BaseColorResult = _BaseColor * _BaseSampleTexture;
				float _AlphaResult = _BaseSampleTexture.a * _BaseColor.w;
				surface.BaseColor = (_BaseColorResult.xyz);
				surface.Alpha = _AlphaResult;
				surface.AlphaClipThreshold = 0.5;
				return surface;
			}
			
			VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
			{
				VertexDescriptionInputs output;
				ZERO_INITIALIZE(VertexDescriptionInputs, output);
				
				output.ObjectSpaceNormal =                          input.normalOS;
				output.ObjectSpaceTangent =                         input.tangentOS.xyz;
				output.ObjectSpacePosition =                        input.positionOS;
				
				return output;
			}
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
			
				output.uv0 = input.texCoord0;
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
			
			
			ENDHLSL
		}
	}
	CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	FallBack "Hidden/Shader Graph/FallbackError"
}