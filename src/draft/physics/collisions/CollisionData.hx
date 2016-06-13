package draft.physics.collisions;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;

/**
 * ...
 * @author asdf
 */

class CollisionData 
{

	public var shape1:CollisionShape;
	public var shape2:CollisionShape;
	public var manifold:Manifold;
	public var stepIndex:Int;
	
	public function new()
	{
		
	}
	
}