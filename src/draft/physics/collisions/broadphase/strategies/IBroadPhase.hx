/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.broadphase.strategies;
import draft.math.AABB2D;
import draft.physics.collisions.broadphase.CollisionShapeProxy;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.ContactManager;

interface IBroadPhase 
{
	function commit():Void;
	function setContactManager(manager:ContactManager):Void;
	
	function createProxy(shape:CollisionShape):Int;
	function removeProxy(id:Int):Void;
	
	function getProxy(proxyId:Int):CollisionShapeProxy;
	
	
}