/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.broadphase;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.Contact;

interface IPairCallback 
{

	function pairAdded(shape1:CollisionShape, shape2:CollisionShape):Contact;
	function pairRemoved(contact:Contact):Void;
	
}