Shader "Custom/SolidColor"
{
    Properties
    {
        _Color ("Tint", Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            //PRAGMAS para que el vertex y fragment shader compilen
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            //VARIABLES GLOBALES DE CONEXION DE LAS PROPIEDADES
            uniform fixed4 _Color;

            //VERTEX INPUT (struct)
            struct vertexInput
            {
                //Esta variable guardara las coordenadas iniciales de los vertices del objeto (local/object space), en sus ejes x,y,z,w
                fixed4 vertex : POSITION;
            }; //Los struct se cierran con ;


            //VERTEX OUTPUT (struct)
            struct vertexOutput
            {
                //Guardara las nuevas posiciones de los vertices del objeto a proyectar en pantalla (projection space)
                fixed4 position : SV_POSITION;
                
                //Guardara el color final de los pixeles que ocupan el area de los vertices en sus canales r,g,b,a
                fixed4 color : COLOR;
            }; //Los struct terminan con ;

            //VERTEX SHADER (funcion, procesa los vertices, tipo de dato vertexOutput, se le pasa como parametro la posicion de los vertices con un puntero de tipo vertexInput)
            vertexOutput vertexShader(vertexInput i)
            {
                //Variable "o" tipo vertexOutput que guardara los datos de salida de los vertices una vez procesados (position y color), por eso vertexShader es del mismo tipo, porque retornara esta variable
                vertexOutput o;

                //UnityObjectToClipPos() transforma la posicion de los vertices a coordenadas en pantalla, pasandole como parametro los vertices del objeto
                o.position = UnityObjectToClipPos(i.vertex); //Funcion original

                /*
                //Explicacion de la coordenada w
                float x = i.vertex.x;
                float y = i.vertex.y;
                float z = i.vertex.z;
                float w = 1; //Coordenada homogenea
                i.vertex = float4(x,y,z,w);

                //Explicacion del UNITY_MATRIX_MVP
                o.position = mul(unity_ObjectToWorld, i.vertex);
                o.position = mul(UNITY_MATRIX_V, o.position);
                o.position = mul(UNITY_MATRIX_P, o.position);
                */

                //Asigna el color de los pixeles que ocupan el area de los vertices
                o.color = _Color;

                //Retorna "o"
                return o;
            }

            //FRAGMENT SHADER (funcion, procesa los pixeles, tipo de dato fixed4, se le pasa como parametro un puntero al vertexOutput, SV_TARGET corresponde al output del pixel, por eso la funcion tiene efecto en el)
            fixed4 fragmentShader(vertexOutput o) : SV_TARGET
            {
                //Retorna el color de la variable que se paso como parametro, el cual es de tipo fixed4, por eso la funcion es del mismo tipo
                return o.color;
            }

            ENDCG
        }
    }
    Fallback "Mobile/VertexLit"
}