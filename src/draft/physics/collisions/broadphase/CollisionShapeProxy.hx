/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.broadphase;
import draft.physics.collisions.shapes.CollisionShape;

class CollisionShapeProxy 
{
	public static inline var NULL_PROXY = 0x4FFFFFFF;
	
	public var prev:CollisionShapeProxy;
	public var next:CollisionShapeProxy;
	
	public var shape:CollisionShape;
	public var overlapCount:Int;
	
	public var id:Int;
	public var timeStamp:Int;
	
	public function new() 
	{
		
	}
	
}