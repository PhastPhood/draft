package game;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.Vector;

/**
 * ...
 * @author asdf
 */

class Camera2D 
{

	public var orthoMatrix:Matrix3D;
	public var viewPort:Rectangle;
	public var matrix:Matrix3D;
	public function new(w:Int, h:Int) 
	{
		viewPort = new Rectangle(0, 0, w, h);
		orthoMatrix = new Matrix3D(Vector.ofArray
		([
			2/w, 0  ,       0,        0,
			0  , 2/h,       0,        0,
			0  , 0  , 1/(100-0), -0/(100-0),
			0  , 0  ,       0,        1
		]));
		matrix = new Matrix3D();
	}
	
	public function updateMatrix():Void
	{
		matrix.identity();
		matrix.appendTranslation(-viewPort.x - viewPort.width * 0.5, viewPort.y + viewPort.height * 0.5, 0);
		matrix.append(orthoMatrix);
	}
	
}