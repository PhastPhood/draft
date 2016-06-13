/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.Contact;

interface ICollisionHandler 
{

	function collide(shape1:CollisionShape, shape2:CollisionShape, contact:Contact):Void;
	
}
