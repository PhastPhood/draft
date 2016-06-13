/**
 * ...
 * @author Jeffrey Gao
 */

package draft.math;

class AABB2D 
{

	public var min:Vector2D;
	public var max:Vector2D;
	
	public function new(minx:Float = 0, miny:Float = 0, maxx:Float = 0, maxy:Float = 0) 
	{
		min = new Vector2D(minx, miny);
		max = new Vector2D(maxx, maxy);
	}
	
	public function clone():AABB2D 
	{
		var c:AABB2D = new AABB2D();
		c.min = min.clone();
		c.max = max.clone();
		return new AABB2D(min.x, min.y, max.x, max.y);
	}
	
	public function toString():String
	{
		return ("min: " + min.toString() + ", max: " + max.toString());
	}
}