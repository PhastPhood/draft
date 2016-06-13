package draft.graphics.shaders;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;

/**
 * ...
 * @author asdf
 */

interface IShader2D 
{

	function apply(buffer:VertexBuffer3D, texture:Texture, transform:Matrix3D, cameraTransform:Matrix3D, data:Array<Float> = null):Void;
	
}