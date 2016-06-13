/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.forces;
import draft.math.Vector2D;
import draft.physics.dynamics.RigidBody;

class Spring extends ForceGenerator
{

	public var k:Float;
	public var b:Float;
	public var point:Vector2D;
	
	public function new(p:Vector2D, k:Float, b:Float) 
	{
		super();
		point = p;
		this.k = k;
		this.b = b;
	}
	
	override public function applyForce(body:RigidBody):Void
	{
			var dx:Float = body.worldCenterOfMass.x - point.x;
			var dy:Float = body.worldCenterOfMass.y - point.y;
			body.accumulatedForce.x += -k * dx - b * body.velocity.x;
			body.accumulatedForce.y += -k * dy - b * body.velocity.y;
	}
	
}