Shader "Custom/Kusa" {
	Properties {
		_B("bend", Float) = 1
		_C1("color1", Color) = (0,0,0,1)
		_C2("color2", Color) = (1,1,1,1)
		_Y ("yure", Vector) = (1,0,0,0)
	}
	SubShader {
	CGINCLUDE
		#define PI 3.14159265359
	
		float _B;
		float4 _C1,_C2,_Y;
		
		struct Input {
			float4 vColor;
		};
		
		float3 rotateX(float3 v, float angle){
			float s,c;
			sincos(angle,s,c);
			float4x4 rot = float4x4(
				1, 0, 0, 0,
				0, c,-s, 0,
				0, s, c, 0,
				0, 0, 0, 1
			);
			return mul(rot, float4(v,1)).xyz;
		}
		float3 rotateX(float3 v, float angle, float3 center){
			v -= center;
			v = rotateX(v, angle);
			v += center;
			return v;
		}
		
		float3 rotateY(float3 v, float angle){
			float s,c;
			sincos(angle,s,c);
			float4x4 rot = float4x4(
				c, 0, s, 0,
				0, 1, 0, 0,
			   -s, 0, c, 0,
				0, 0, 0, 1		
			);
			return mul(rot, float4(v,1)).xyz;
		}
		float3 rotateY(float3 v, float angle, float3 center){
			v -= center;
			v = rotateY(v, angle);
			v += center;
			return v;
		}
		
		void vert (inout appdata_full v, out Input o){
			UNITY_INITIALIZE_OUTPUT(Input,o);
			
			float rot = v.color.r;
			float grow = v.color.g;
			float bend = 1-v.color.b;
			
			float3 pos = v.vertex.xyz;
			float3 bendCenter = float3(pos.x, 0, pos.z);
			float3 rotCenter = float3(pos.x, 0, pos.z);
			
			pos.y *= grow*grow;
			pos = rotateX(pos, bend * v.vertex.y * v.vertex.y * _B, bendCenter);
			pos = rotateY(pos, rot * 2 * PI, rotCenter);
			pos += _Y.xyz * sin(_Time.y + pos.x) * pos.y;
			v.vertex.xyz = pos;
			
			o.vColor = lerp(_C1,_C2,saturate(grow*pos.y));
			o.vColor.a *= saturate(pos.y * 10-1);
		}
 
		void surf (Input IN, inout SurfaceOutput o) {
			o.Emission = IN.vColor;
			o.Alpha = IN.vColor.a;
		}
	
	ENDCG
		
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		ZWrite On
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert noforwardadd alpha
		#pragma target 3.0
		#pragma glsl
		
		ENDCG
	} 
	FallBack "Diffuse"
}