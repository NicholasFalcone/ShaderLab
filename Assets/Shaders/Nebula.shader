Shader "StarMap/Raycast Nebula"
{
	Properties
	{
		// Noise References http://kitfox.com/projects/perlinNoiseMaker/
		// Assign a 256x256 blue noise texture to the material's _MainTex property
		_MainTex("Texture", 2D) = "white" {}
		_CentralColorExposure("Central Color Exposure", float) = 7
		_EdgeColorExposure("Edge Color Exposure", float) = 1.5
		_InternalColor("Internal Color", Color) = (1,1,1,1)
		_ExternalColor("External Color", Color) = (1,1,1,1)

	}

		SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"ForceNoShadowCasting" = "True"
			"CanUseSpriteAtlas" = "False"
			"PreviewType" = "Plane"
		}

		Blend SrcAlpha One
		ZWrite Off
		ZTest Less

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing

			#include "UnityCG.cginc"

			const float nudge = 0.739513;	// size of perpendicular vector
			
			sampler2D _MainTex;

			float _CentralColorExposure;
			float _EdgeColorExposure;

			float4 _InternalColor;

			float4 _ExternalColor;

			float4 _MainTex_ST;

			struct appdata
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv	: TEXCOORD0;
				float4 pos	: SV_POSITION;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			#define pi 3.14159265
			#define R(p, a) p= cos(a) * p + sin(a) * float2(p.y, -p.x)

			// iq's noise
			float noise(in float3 x)
			{
				float3 p = floor(x);
				float3 f = frac(x);
				f = f * f * (3.0 - 2.0 * f);

				float2 uv = (p.xy + float2(37.0, 17.0) * p.z) + f.xy;
				float2 rg = tex2D(_MainTex, (uv + 0.5) / 256.0).yx;

				return 1.0 - 0.82 * lerp(rg.x, rg.y, f.z);
			}

			float rand(float2 co)
			{
				return frac(sin(dot(co * 0.123, float2(12.9898, 78.233))) * 43758.5453);
			}

			float SpiralNoiseC(float3 p)
			{
				float normalizer = 1.0 / sqrt(1.0 + nudge * nudge);	// Pythagorean theorem on that perpendicular to maintain scale

				float n = 0.0;	// noise amount
				float iter = 1.0;

				for (int i = 0; i < 8; i++)
				{
					// add sin and cos scaled inverse with the frequency
					n += -abs(sin(p.y * iter) + cos(p.x * iter)) / iter;	// abs for a ridged look

					// rotate by adding perpendicular and scaling down
					p.xy += float2(p.y, -p.x) * nudge;
					p.xy *= normalizer;

					// rotate on other axis
					p.xz += float2(p.z, -p.x) * nudge;
					p.xz *= normalizer;

					// increase the frequency
					iter *= 1.733733;
				}

				return n;
			}

			float SpiralNoise3D(float3 p)
			{
				float normalizer = 1.0 / sqrt(1.0 + nudge * nudge);	// Pythagorean theorem on that perpendicular to maintain scale

				float n = 0.0;
				float iter = 1.0;

				for (int i = 0; i < 5; i++)
				{
					n += (sin(p.y * iter) + cos(p.x * iter)) / iter;
					p.xz += float2(p.z, -p.x) * nudge;
					p.xz *= normalizer;
					iter *= 1.33733;
				}

				return n;
			}

			float NebulaNoise(float3 p)
			{
				float final = p.y + 4.5;
				final -= SpiralNoiseC(p.xyz);   // mid-range noise
				final += SpiralNoiseC(p.zxy * 0.5123 + 100.0) * 4.0;   // large scale features
				final -= SpiralNoise3D(p);   // more large scale features, but 3d

				return final;
			}

			float map(float3 p)
			{
#ifdef ROTATION
				R(p.xz, iMouse.x * 0.008 * pi + iTime * 0.1);
#endif

				R(p.xz, _Time.y * 0.1);

				float NebNoise = abs(NebulaNoise(p / 0.5) * 0.5);

				return NebNoise + 0.03;
			}

			// assign color to the media
			float3 computeColor(float density, float radius)
			{
				// color based on density alone, gives impression of occlusion within
				// the media
				float3 result = lerp(float3(1.0, 0.9, 0.8), float3(0.4, 0.15, 0.1), density);

				// color added to the media
				float3 colCenter = _CentralColorExposure * float3(0.8, 1.0, 1.0);
				float3 colEdge = _EdgeColorExposure * float3(0.48, 0.53, 0.5);
				result *= lerp(colCenter, colEdge, min((radius + 0.05) / 0.9, 1.15));

				return result;
			}

			bool RaySphereIntersect(float3 org, float3 dir, out float near, out float far)
			{
				float b = dot(dir, org);
				float c = dot(org, org) - 8.0;
				float delta = b * b - c;

				if (delta < 0.0)
					return false;

				float deltasqrt = sqrt(delta);
				near = -b - deltasqrt;
				far = -b + deltasqrt;

				return far > 0.0;
			}

			float3 ToneMapFilmicALU(float3 _color)
			{
				_color = max(float3(0, 0, 0), _color - float3(0.004, 0.004, 0.004));
				_color = (_color * (6.2 * _color + float3(0.5, 0.5, 0.5))) / (_color * (6.2 * _color + float3(1.7, 1.7, 1.7)) + float3(0.06, 0.06, 0.06));

				return _color;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;

				float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
				float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
				float4 outPos = mul(UNITY_MATRIX_P, viewPos);

				o.pos = outPos;
				o.uv = v.uv.xy;

				return o;
			}

			fixed4 frag(v2f input) : SV_Target
			{
				float3 fragCoord = input.pos;
				float iTime = _Time.y;
				float key = 0.0;

				// ro: ray origin
				// rd: direction of the ray
				float3 rd = normalize(float3((fragCoord.xy - 0.5 * _ScreenParams.xy) / _ScreenParams.y, 1.0));
				float3 ro = float3(0.0, 0.0, -6.0 + key * 1.6);

				R(rd.yz, -pi * 3.93);
				R(rd.xz, pi * 3.2);
				R(ro.yz, -pi * 3.93);
				R(ro.xz, pi * 3.2);

				float2 dpos = (fragCoord.xy / _ScreenParams.xy);
				float2 seed = dpos + frac(iTime);

				// ld, td: local, total density 
				// w: weighting factor
				float ld = 0.0;
				float td = 0.0;
				float w = 0.0;

				// t: length of the ray
				// d: distance function
				float d = 1.0;
				float t = 0.0;

				const float h = 0.1;

				float4 sum = float4(0, 0, 0, 0);

				float min_dist = 0.0, max_dist = 0.0;

				if (RaySphereIntersect(ro, rd, min_dist, max_dist))
				{

					t = min_dist * step(t, min_dist);

					// raymarch loop
					for (int i = 0; i < 56; i++)
					{

						float3 pos = ro + t * rd;

						// Loop break conditions.
						if (td > 0.9 || d < 0.1 * t || t>10.0 || sum.a > 0.99 || t > max_dist)
						{
							break;
						}

						// evaluate distance function
						float d = map(pos);

						// change this string to control density 
						d = max(d, 0.08);

						// point light calculations
						float3 ldst = float3(0, 0, 0) - pos;
						float lDist = max(length(ldst), 0.001);

						// star in center
						float3 lightColor = _InternalColor;
						sum.rgb += (lightColor / (lDist * lDist) / 30.); // star itself and bloom around the light

						if (d < h)
						{
							// compute local density 
							ld = h - d;

							// compute weighting factor 
							w = (1. - td) * ld;

							// accumulate density
							td += w + 1. / 200.;

							float4 col = float4(computeColor(td, lDist), td);

							// uniform scale density
							col.a *= 0.185;

							// colour by alpha
							col.rgb *= col.a;

							// alpha blend in contribution
							sum = sum + col * (1.0 - sum.a);
						}

						td += 1.0 / 70.0;

						// enforce minimum step size
						d = max(d, 0.04);

						// add in noise to reduce banding and create fuzz
						d = abs(d) * (0.8 + 0.2 * rand(seed * float2(i, i)));

						// trying to optimize step size near the camera and near the light source
						t += max(d * 0.1 * max(min(length(ldst), length(ro)), 1.0), 0.02);
					}

					// simple scattering
					sum *= 1.0 / exp(ld * 0.2) * 0.6;

					sum = clamp(sum, 0.0, 1.0);

					sum.xyz = sum.xyz * sum.xyz * (3.0 - 2.0 * sum.xyz);
				}

				float4 fragColor = float4(ToneMapFilmicALU(sum.xyz * 2.2), 1.0);

				fixed4 colorTex = tex2D(_MainTex, input.uv);

				return fragColor;
			}

			ENDCG
		}
	}
}