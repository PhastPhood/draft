package draft.graphics.shaders;
import flash.display3D.Context3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;

/**
 * ...
 * @author asdf
 */
class StandardShader extends hxsl.Shader implements IShader2D
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
		function fragment( tex : Texture ) {
			out = tex.get(tuv);
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
		trans = transform;
		camera = cameraTransform;
		tex = texture;
		bind(context, buffer);
	}
	
}