/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.forces;
import draft.math.Vector2D;
import draft.physics.dynamics.RigidBody;

class SimpleGravity extends ForceGenerator
{

	public var force:Vector2D;
	
	public function new(forceX:Float = 0, forceY:Float = 0) 
	{
		super();
		force = new Vector2D();
		force.x = forceX;
		force.y = forceY;
	}
	
	override public function applyForce(body:RigidBody):Void
	{
		body.accumulatedForce.x += force.x * body.mass;
		body.accumulatedForce.y += force.y * body.mass;
	}
	
}