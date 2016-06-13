/**
 * ...
 * @author Jeffrey Gao
 */

package draft.math;

class RotationMatrix2D 
{

	public var angle:Float;
	public var i1j1:Float;
	public var i1j2:Float;
	public var i2j1:Float;
	public var i2j2:Float;
	
	public function new(?x:Float = 0) 
	{
		if (x != 0) {
			angle = x;
			angle %= 6.283185307179586;
			i1j1 = MathApprox.cos(angle);
			i2j1 = MathApprox.sin(angle);
			i1j2 = -i2j1;
			i2j2 = i1j1;
		}else {
			angle = 0;
			i1j1 = 1;
			i1j2 = 0;
			i2j1 = 0;
			i2j2 = 1;
		}
	}
	
	public function setAngle(?x:Float):Void
	{
		if (Math.isNaN(x))
			return;
		angle = x;
		angle %= 6.283185307179586;
		i1j1 = MathApprox.cos(angle);
		i2j1 = MathApprox.sin(angle);
		i1j2 = -i2j1;
		i2j2 = i1j1;
	}
	
	public function clone():RotationMatrix2D 
	{
		var c:RotationMatrix2D = new RotationMatrix2D();
		c.angle = angle;
		c.i1j1 = i1j1;
		c.i1j2 = i1j2;
		c.i2j1 = i2j1;
		c.i2j2 = i2j2;
		return c;
	}
	
	public function toString():String{
		return ("angle: " + angle + ", Matrix: [i1j1: " + i1j1 + ", i2j1: " + i2j1 + ", i1j2: " + i1j2 + ", i2j2: " + i2j2 + "]");
	}
	
}