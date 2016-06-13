/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.contacts;

class ContactID 
{

	public var key:UInt;
	public var incidentEdge:Int;
	public var referenceEdge:Int;
	public var incidentVertex:Int;
	public var flip:Int;
	
	public function new()
	{
		
	}
	
	public inline function generateKey():Void
	{
		key = referenceEdge << 21;
		key |= incidentEdge << 11;
		key |= incidentVertex << 1;
		key |= flip;
	}
	
	public inline function setKey(newKey:UInt):Void
	{
		key = newKey;
		flip = key & 1;
		incidentVertex = (key & 0x000007FE) >> 1;
		incidentEdge = (key & 0x001FF800) >> 11;
		referenceEdge = (key & 0x7FE0F800) >> 21;
		
	}
	
}