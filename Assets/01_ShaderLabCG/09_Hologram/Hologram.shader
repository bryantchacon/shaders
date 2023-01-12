Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Hologram ("Hologram", 2D) = "white" {} //Propiedad para el efecto
        _Color ("Color", Color) = (1,1,1,1)
        _Frequency ("Frequency", Range(1, 30)) = 15
        _Speed ("Speed", Range(0, 5)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        Blend SrcAlpha One //Blend aditivo

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 huv : TEXCOORD1; //Variable para las UVs de _Hologram
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Hologram; //Variable de coneccion de _Hologram
            float4 _Color;
            float _Frequency;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.huv = v.uv; //Las UVs de _Hologram seran las mismas del objeto para que tengan la misma posicion que las de la textura principal
                o.huv.y -= _Time * _Speed; //Se agrega tiempo a la coordenada V (por .y) con _Time y se multiplica por _Speed para que se mueva y se pueda controlar su velocidad desde el inspector, con - se mueve hacia arriba, con + hacia abajo, con * el efecto se va acumulando y sin nada el shader ya no parece holograma y parpadea en color solido
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color; //Para agregar el color se multiplica por la textura principal
                fixed4 holo = tex2D(_Hologram, i.huv); //Asigna la textura del holograma al objeto

                // col.a = sqrt(i.uv.y); //Al alpha de la textura (porque la variable col guarda la textura) se le asigna la coordenada V de los UVs (esto porque U = x y V = y), y asi la coordenada Y tendra un degradado de abajo hacia arriba, y esto se pone en la funcion sqrt() para que el nivel de degradado sea segun su curvatura matematica

                // col.a = abs(sin(i.uv.y * 20)); //Con sin() dara un resultado similar a como si no tuviera operacion matematica, con sin() y multiplicado por 20 hara que el degradado sea rayado porque el resultado son curvas en el eje X, pero esto tiene el inconveniente de que las areas transparentes del alpha seran muy amplias debido a que sin() tambien regresa numeros negativos pero en las coordenadas UV no los hay, asi que basta con usar la funcion abs() (absolute), para que solo regrese numeros positivos

                // col.a = abs(tan(i.uv.y * _Frequency));

                holo.a = abs(sin(i.huv.y * _Frequency)); //La textura holografica se asigna al canal alpha de holo y en lugar de tan, sera sin para un mejor degradado en los bordes de las lineas holograficas
                return col * holo; //Finalmente para agregar el efecto se multiplica la textura principal por holo

                //PARA MAS INFORMACION DE LAS FUNCIONES MATEMATICAS DE CG CHECAR: https://developer.download.nvidia.com/CgTutorial/cg_tutorial_appendix_e.html
            }
            ENDCG
        }
    }
}