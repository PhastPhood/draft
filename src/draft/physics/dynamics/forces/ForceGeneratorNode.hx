/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.forces;

class ForceGeneratorNode 
{

	public var force:ForceGenerator;
	public var prev:ForceGeneratorNode;
	public var next:ForceGeneratorNode;
	
	public function new(forceGenerator:ForceGenerator) 
	{
		force = forceGenerator;
	}
	
	public function free():Void
	{
		if (prev != null)
			prev.next = next;
		if (next != null)
			next.prev = prev;
		next = null;
		prev = null;
		force = null;
	}
	
}