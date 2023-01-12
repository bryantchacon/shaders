Shader "Custom/Instancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //Pragma para poder usar los macros que hacen posible el instancing y agrega la casilla “Enable GPU Instancing” en el shader inspector la cual se debe activar, paso 1/3
            //NOTA: Antes de empezar se debe verificar que el Rendering Path sea igual a Forward en: Main Camera > Camera > Rendering Path > Forward
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID //Argega un ID a cada instancia del objeto, paso 2/3
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v); //Se pasa v como parametro porque en el esta el ID que se agrego en el vertex input con UNITY_VERTEX_INPUT_INSTANCE_ID, para que se pueda identificar una instancia de otra al renderizarse (siempre ira antes de o.vertex = UnityObjectToClipPos(v.vertex)), paso 3/3
                //NOTA: Para mas info sobre GPU Instancing checar: https://docs.unity3d.com/Manual/GPUInstancing.html, en ella se pueden ver otras opciones como variaciones de instancia a través de cambio de color, o escala

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}