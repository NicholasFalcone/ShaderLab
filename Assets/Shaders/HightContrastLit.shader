Shader "Custom/HightContrastLit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color)  = (.25, .5, .5, 1) 

        _ShadowMultiplier ("ShadowMultiplier", Color)  = (.25, .5, .5, 1) 
        _LightMultiplier ("LightMultiplier", Color)  = (.25, .5, .5, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
 
        Pass
        {
            Tags{ "LightMode" = "UniversalForward" }
 
            CGPROGRAM
 
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
 
            #pragma multi_compile_fwdbase// nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;                              
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
            };
 
            sampler2D _MainTex;
            float4 _BaseColor;
            float4 _ShadowMultiplier;
            float4 _LightMultiplier;
            float4 _MainTex_ST;
 
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
 
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                
                if(nl > .5f){
                    o.diff = nl * _BaseColor * _LightMultiplier;
                }
                else{
                    o.diff = nl *  _ShadowMultiplier;
                }
                o.ambient = ShadeSH9(half4(worldNormal, 1)) ;
               
                // TRANSFER_SHADOW(o)
 
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

                fixed4 col = tex2D(_MainTex, i.uv);
 
                fixed3 lighting = i.diff;
 
                col.rgb *= lighting;
 
                return col;
            }
            ENDCG
        }
 
        // shadow casting support
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
