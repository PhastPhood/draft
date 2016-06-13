/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.broadphase.strategies;
import draft.physics.collisions.broadphase.CollisionShapeProxy;
import draft.physics.collisions.broadphase.PairManager;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.collisions.shapes.RectangleShape;
import draft.physics.dynamics.contacts.ContactManager;

class BruteForce implements IBroadPhase
{
	
	public var contactManager:ContactManager;
	public var pairManager:PairManager;
	public var proxyArray:Array<CollisionShapeProxy>;
	public var proxyListHead:CollisionShapeProxy;
	public var proxyListTail:CollisionShapeProxy;

	public function new() 
	{
		proxyArray = new Array<CollisionShapeProxy>();
		
		pairManager = new PairManager();
		pairManager.broadPhase = this;
	}
	
	public function commit():Void
	{
		
		var proxy1:CollisionShapeProxy = proxyListHead;
		var proxy2:CollisionShapeProxy;
		var shape1:CollisionShape;
		var shape2:CollisionShape;
		while (proxy1 != null)
		{
			shape1 = proxy1.shape;
			proxy2 = proxy1.next;
			while (proxy2 != null)
			{

				shape2 = proxy2.shape;
				if (shape1.body == shape2.body){
					proxy2 = proxy2.next;
					continue;
				}
					
				if (shape1.body.isStatic) {
					if (shape2.body.isStatic){
						proxy2 = proxy2.next;
						continue;
					}
				}
				if (shape1.AABB.max.x < shape2.AABB.min.x ||
					shape1.AABB.min.x > shape2.AABB.max.x ||
					shape1.AABB.max.y < shape2.AABB.min.y ||
					shape1.AABB.min.y > shape2.AABB.max.y) {
					if (proxy1.overlapCount * proxy2.overlapCount > 0) {
						if (pairManager.removePair(proxy1.id, proxy2.id)) {
							proxy1.overlapCount--;
							proxy2.overlapCount--;
						}
					}
				}else {
					if (pairManager.addOrUpdatePair(proxy1.id, proxy2.id)) {
						proxy1.overlapCount++;
						proxy2.overlapCount++;
						
	
					}
				}
				proxy2 = proxy2.next;
			}
			proxy1 = proxy1.next;
		}
	}
	
	public function setContactManager(manager:ContactManager):Void
	{
		contactManager = manager;
		pairManager.pairCallback = manager;
	}
	
	public function createProxy(shape:CollisionShape):Int
	{
		var proxy:CollisionShapeProxy = new CollisionShapeProxy();
		proxy.shape = shape;
		var proxyId:Int = proxyArray.push(proxy) - 1;
		proxy.id = proxyId;
		
		if (proxyListHead == null) {
			proxyListHead = proxyListTail = proxy;
			proxyListHead.next = proxyListTail;
		}else {
			proxyListTail.next = proxy;
			proxy.prev = proxyListTail;
			proxyListTail = proxy;
		}
		
		return proxyId;
	}
	
	public function removeProxy(id:Int):Void
	{
		
	}
	
	public function getProxy(proxyId:Int):CollisionShapeProxy
	{
		return proxyArray[proxyId];
	}
	
	
}