/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.broadphase;
import draft.physics.dynamics.contacts.Contact;

class Pair 
{
	public var prev:Pair;
	public var next:Pair;
	public var proxyId1:Int;
	public var proxyId2:Int;
	public var contact:Contact;
	public var active:Bool;
	public var updated:Bool;
	
	public function new() 
	{
		active = false;
		updated = false;
	}
	
}