/**
 * ...
 * @author Jeffrey Gao
 */

package draft.math;

class MathApprox
{

	public static inline function sin(x:Float):Float
	{	
		var pi:Float = Math.PI;
		var pi2:Float = pi * 2;
		
		if (x > pi)
			x -= pi2 * Std.int(x / pi2 + 0.5);
		else if (x < pi)
			x -= pi2 * Std.int(x / pi2 - 0.5);
			
		var sin:Float = 1.27323954 * x;
		sin += x < 0 ? 0.405284735 * x * x : -0.405284735 * x * x;
		sin = sin < 0 ? .225 * (sin * -sin - sin) + sin : .225 * (sin * sin -sin) + sin;
		return sin;
	}
	
	public static inline function cos(x:Float):Float
	{
		x += Math.PI * 0.5;
		return sin(x);
	}
	
	public static inline function invSqrt(x:Float):Float
	{
		var half:Float = 0.5 * x;
		flash.Memory.setFloat(0, x);
		var i:Int = flash.Memory.getI32(0);
		i = 0x5f3759df - (i >> 1);
		flash.Memory.setI32(0, i);
		x = flash.Memory.getFloat(0);
		x = x * (1.5 - half * x * x);
		return x;
	}
}