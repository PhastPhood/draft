package draft.graphics.shaders.obnoxious;
import draft.graphics.shaders.IShader2D;
import flash.display3D.Context3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.sampler.NewObjectSample;

/**
 * ...
 * @author asdf
 */
class SharpenShader extends hxsl.Shader implements IShader2D
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
		function fragment( tex : Texture , rad:Float, str:Float) {
			var o:Float4 = tex.get(tuv);
			o += tex.get(tuv  + [rad, rad]) * str;
			o -= tex.get(tuv  - [rad, rad]) * str;
			out = o;
		}
	}
	public var r:Float;
	public var s:Float;
	public var context:Context3D;
	public function new(c:Context3D) 
	{
		super();
		r = 0.001;
		s = 2;
		context = c;
	}
	
	public function apply(buffer:VertexBuffer3D, texture:Texture, transform:Matrix3D, cameraTransform:Matrix3D, data:Array<Float> = null):Void
	{
		trans = transform;
		camera = cameraTransform;
		tex = texture;
		rad = r;
		str = s;
		bind(context, buffer);
	}
	
}