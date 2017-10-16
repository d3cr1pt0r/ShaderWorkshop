// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderWorkshop/VFX/Portal"
{
    Properties
    {
        _TwirlTex ("Twirl Texture", 2D) = "black" {}
        _DistortionTex ("Distortion Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _Falloff ("Falloff", Range(1, 0)) = 0
        _OuterGlowColor ("Outer Glow Color", Color) = (1,1,1,1)
        _OuterGlowWidth ("Outer Glow Width", Range(0, 1)) = 0
        _OuterGlowSharpness ("Outer Glow Sharpness", Range(0, 30)) = 3
        _OuterGlowDistortionAmmount ("Outer Glow Distortion Ammount", range(-50, 50)) = 1
        _InnerGlowColor ("Inner Glow Color", Color) = (1,1,1,1)
        _InnerGlowWidth ("Inner Glow Width", Range(0, 1)) = 0
        _InnerGlowSharpness ("Inner Glow Sharpness", Range(0, 30)) = 3
        _InnerGlowDistortionAmmount ("Inner Glow Distortion Ammount", Range(-50, 50)) = 1
        _GlowDistortionSpeedX ("Glow Distortion Speed X", Range(-1, 1)) = 0.1
        _GlowDistortionSpeedY ("Glow Distortion Speed Y", Range(-1, 1)) = 0.1
        _RotationSpeed ("Rotation", Float) = 0
        _LimX ("LimX", Float) = 2
        _LimY ("LimY", Float) = 2
        _PowX ("PowX", Float) = 2
        _PowY ("PowY", Float) = 2
        [KeywordEnum(Additive, Alphablend)] _Blend("Inner Glow Blend Mode", Float) = 0
    }
    SubShader
    {
        Tags {  }
        Blend One OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _BLEND_ADDITIVE _BLEND_ALPHABLEND
            #include "UnityCG.cginc"
            sampler2D _TwirlTex;
            sampler2D _DistortionTex;
            fixed4 _TintColor;
            half _Falloff;
            half4 _DistortionTex_ST;
            fixed4 _OuterGlowColor;
            half _OuterGlowWidth;
            half _OuterGlowSharpness;
            fixed4 _InnerGlowColor;
            half _InnerGlowWidth;
            half _InnerGlowSharpness;
            half _PowX;
            half _PowY;
            half _LimX;
            half _LimY;
            half _RotationSpeed;
            half _OuterGlowDistortionAmmount;
            half _InnerGlowDistortionAmmount;
            half _GlowDistortionSpeedX;
            half _GlowDistortionSpeedY;
            struct vertex_input
            {
                float4 vertex : POSITION;
                fixed2 texcoord : TEXCOORD0;
            };
            struct vertex_output
            {
                float4 vertex : SV_POSITION;
                fixed2 texcoord : TEXCOORD0;
                fixed2 texcoord_d : TEXCOORD1;
                fixed2 texcoord_rot : TEXCOORD2;
            };
            
            vertex_output vert (vertex_input v)
            {
                vertex_output o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                o.texcoord_d = TRANSFORM_TEX(v.texcoord, _DistortionTex);
                o.texcoord_rot.xy = v.texcoord - fixed2(0.5, 0.5);
                half sinX = sin ( _RotationSpeed );
                half cosX = cos ( _RotationSpeed );
                half2x2 rotationMatrix = float2x2( cosX, -sinX, sinX, cosX);
                o.texcoord_rot.xy = mul ( o.texcoord_rot.xy, rotationMatrix );
                o.texcoord_rot.xy += fixed2(0.5, 0.5);
                return o;
            }
            
            fixed4 frag (vertex_output i) : SV_Target
            {
                fixed3 twirl_color = tex2D(_TwirlTex, i.texcoord_rot).rgb;
                fixed3 d = tex2D(_DistortionTex, i.texcoord_d + frac(fixed2(_Time.y * _GlowDistortionSpeedX, _Time.y * _GlowDistortionSpeedY))).rgb;
                // fix
                _InnerGlowWidth = max(0.0000001, _InnerGlowWidth);
                // calculate radial gradient
                half2 newSpace = abs(i.texcoord * 2 - 1) * half2(_LimX, _LimY);
                half twirl_gradient = 1.0 - sqrt((pow(newSpace.x, _PowX) + pow(newSpace.y, _PowY)));
                // falloff mask
                half os = step(twirl_gradient, _Falloff);
                // inverted mask
                half is = 1.0 - os;
                // calculate outer glow gradient color
                half og_ss = saturate(pow(smoothstep(_Falloff - _OuterGlowWidth, _Falloff, twirl_gradient) * os, _OuterGlowSharpness) * (1.0 - (d.x * d.y) * _OuterGlowDistortionAmmount)); 
                half3 og = og_ss * _OuterGlowColor.rgb;
                // calculate inner glow gradient color
                half ig_ss = saturate(pow(smoothstep(_Falloff + _InnerGlowWidth, _Falloff, twirl_gradient) * is, _InnerGlowSharpness) * (1.0 - (d.x * d.y) * _InnerGlowDistortionAmmount)) * _InnerGlowColor.a;
                half3 ig = ig_ss * _InnerGlowColor.rgb;
                #if defined(_BLEND_ALPHABLEND)
                    return fixed4((twirl_color * _TintColor.rgb * os * _TintColor.a) + og + ig * ig_ss, os * _TintColor.a + ig_ss);
                #endif
                return fixed4((twirl_color * _TintColor.rgb * os * _TintColor.a) + og + ig, os * _TintColor.a);
            }
            ENDCG
        }
    }
}