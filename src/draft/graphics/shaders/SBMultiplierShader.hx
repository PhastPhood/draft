package draft.graphics.shaders;
import flash.display3D.Context3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import haxe.macro.Format;
import hxsl.Shader;

/**
 * ...
 * @author asdf
 */

class SBMultiplierShader extends Shader implements IShader2D
{

	static var SRC = 
	{
		var input : {
			pos : Float2,
			uv : Float2,
		};
		var tuv : Float2;
		/*
		function vertex(translation : M44, rotation : M44, scale : M44, ortho : M44) {
			out = pos.xyzw * scale * rotation * translation * ortho;
			tuv = uv;
		}//*/
		//*
		function vertex(trans : M44, camera : M44) {
			out = input.pos.xyzw * trans * camera;
			tuv = input.uv;
		}//*/
		function fragment( tex : Texture, saturationMultiplier:Float, brightnessMultiplier:Float ) {
			var colorShift:Float4 = tex.get(tuv);
			var max:Float = max(colorShift.x, colorShift.y);
			max = max(max, colorShift.y);
			var a:Float = saturationMultiplier / max;
			var b:Float = brightnessMultiplier * max;
			colorShift.x = b * (1 - (max - colorShift.x) * a);
			colorShift.y = b * (1 - (max - colorShift.y) * a);
			colorShift.z = b * (1 - (max - colorShift.z) * a);
			out = colorShift;
		}
	}
	
	public var context:Context3D;
	
	public function new(c:Context3D)
	{
		super();
		context = c;
	}
	
	public function apply(buffer:VertexBuffer3D, texture:Texture, transform:Matrix3D, cameraTransform:Matrix3D, data:Array<Float> = null):Void
	{
		if (data == null)
		{
			trans = transform;
			camera = cameraTransform;
			tex = texture;
			saturationMultiplier = 1.0;
			brightnessMultiplier = 1.0;
		}else
		{
			trans = transform;
			camera = cameraTransform;
			tex = texture;
			saturationMultiplier = data[0];
			brightnessMultiplier = data[1];
		}
		bind(context, buffer);
	}
	
}