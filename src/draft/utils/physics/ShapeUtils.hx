/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils.physics;
import draft.math.MathApprox;
import draft.math.RotationMatrix2D;

class ShapeUtils 
{

	public function new() 
	{
		
	}
	public static function createRegularPolygon(n:Int, s:Float):Array<Float> {
		var theta:Float = 2 * Math.PI / n;
		var rotation:RotationMatrix2D = new RotationMatrix2D(-theta);
		var r:Float = s / (MathApprox.sin(theta * 0.5)) * 0.5;
		var poly:Array<Float> = new Array<Float>();
		var curX:Float = r;
		var curY:Float = 0;
		var tX:Float;
		for (i in 0...n) {
			tX = curX;
			curX = rotation.i1j1 * curX + rotation.i1j2 * curY;
			curY = rotation.i2j1 * tX + rotation.i2j2 * curY;
			poly.push(curX);
			poly.push(curY);
		}
		return poly;
	}
}