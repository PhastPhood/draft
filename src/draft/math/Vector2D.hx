/**
 * ...
 * @author Jeffrey Gao
 */

package draft.math;

class Vector2D 
{
	public static inline function ORIGIN():Vector2D
	{
		return new Vector2D();
	}
	
	public var x:Float;
	public var y:Float;
	
	public var next:Vector2D;
	public var prev:Vector2D;
	
	public function new(?x:Float = 0, ?y:Float = 0 ) 
	{
		this.x = x;
		this.y = y;
		
	}
	
	public function clone():Vector2D
	{
		return new Vector2D(x, y);
	}
	
	public function setTo(?x:Float, ?y:Float):Void
	{
		if (Math.isNaN(x))
			this.x = x;
		if (Math.isNaN(y))
			this.y = y;
	}
	
	inline public function toString():String
	{
		return ("<" + x + ", " + y + ">");
	}
	
	inline public function rotate(matrix:RotationMatrix2D):Vector2D
	{
		return new Vector2D(x * matrix.i1j1 + y * matrix.i1j2, x * matrix.i2j1 + y * matrix.i2j2);
	}
	
}