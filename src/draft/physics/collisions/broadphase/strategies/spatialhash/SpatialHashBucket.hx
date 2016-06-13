package draft.physics.collisions.broadphase.strategies.spatialhash;
import draft.physics.collisions.broadphase.CollisionShapeProxy;

/**
 * ...
 * @author ...
 */

class SpatialHashBucket 
{
	public var proxyCount:Int;
	public var proxyArray:Array<CollisionShapeProxy>;
	
	public function new()
	{
		proxyArray = new Array<CollisionShapeProxy>();
	}
	
	
}