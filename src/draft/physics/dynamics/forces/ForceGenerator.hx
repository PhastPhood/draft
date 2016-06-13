/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.forces;
import draft.physics.dynamics.RigidBody;

class ForceGenerator 
{
	
	public var bodyArray:Array<RigidBody>;
	

	public function new() 
	{
		
	}
	
	public function applyForce(body:RigidBody):Void
	{
		
	}
	
	public function addBody(body:RigidBody):Bool
	{
		bodyArray.push(body);
		return true;
	}
	
	public function removeBody(body:RigidBody):Bool
	{
		return bodyArray.remove(body);
	}
	
	public function updateForce():Void
	{
		for (body in bodyArray)
		{
			body.forceUpdate(this);
		}
	}
	
	
}