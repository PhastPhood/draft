/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.contacts;
import draft.physics.collisions.broadphase.IPairCallback;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.RigidBody;
import draft.physics.PhysicsEngine;

class ContactManager implements IPairCallback
{

	public var world:PhysicsEngine;
	public var nullContact:NullContact;
	
	public var contactPoolHead:Contact;
	public var contactPoolTail:Contact;
	
	public var poolSize:Int;
	public var activeContactCount:Int;
	public var allocationContact:Contact;
	
	
	public function new(world:PhysicsEngine) 
	{
		this.world = world;
		
		var poolInitialSize:Int = 100;
		poolSize = poolInitialSize;
		contactPoolHead = new Contact(null, null);
		contactPoolTail = new Contact(null, null);
		nullContact = new NullContact();
		
		contactPoolHead.poolNext = contactPoolTail;
		contactPoolHead.poolPrev = contactPoolTail;
		
		contactPoolTail.poolNext = contactPoolHead;
		contactPoolTail.poolPrev = contactPoolHead;
		
		var c:Contact;
		for (i in 0... poolInitialSize)
		{
			c = new Contact(null, null);
			c.poolNext = contactPoolHead;
			contactPoolHead.poolPrev = c;
			contactPoolHead = c;
			
		}
		
		contactPoolTail.poolNext = contactPoolHead;
		contactPoolHead.poolPrev = contactPoolTail;
		
		allocationContact = contactPoolHead;
		
	}
	
	public function collide():Void
	{
		var body1:RigidBody;
		var body2:RigidBody;
		
		var walker:Contact = world.contactList;
		for (i in 0...world.contactCount) 
		{
			/*if (walker == nullContact)
				continue;*/
			
			if (walker == null || walker.shape1 == null || walker.shape2 == null)
				continue;
			body1 = walker.shape1.body;
			body2 = walker.shape2.body;
			
			if (body1 == null || body2 == null)
				continue;
			if (body1.isSleeping && body2.isSleeping)
			{
				walker = walker.next;
				continue;
			}
			
			walker.update();
			walker = walker.next;
		}
	}
	
	public function pairAdded(shape1:CollisionShape, shape2:CollisionShape):Contact
	{
		if (shape1.collisionGroup == shape2.collisionGroup && shape1.collisionGroup != 0)
		{
			if (shape1.collisionGroup < 0)
				return nullContact;
		}else
		{
			if ((shape1.collisionMask & shape2.collisionCategory == 0) || (shape2.collisionMask & shape1.collisionCategory == 0))
				return nullContact;
		}
		
		var body1:RigidBody = shape1.body;
		var body2:RigidBody = shape2.body;
		
		if (body1.isStatic && body2.isStatic)
		{
			return nullContact;
		}
		
		if (body1 == body2)
			return nullContact;
		
		var contact:Contact = createContact(shape1, shape2);
		
		if (contact == null)
			return nullContact;
			
		shape1 = contact.shape1;
		shape2 = contact.shape2;
		
		body1 = shape1.body;
		body2 = shape2.body;
		
		contact.prev = null;
		contact.next = world.contactList;
		
		if (world.contactList != null)
			world.contactList.prev = contact;
			
		world.contactList = contact;
		
		contact.node1.contact = contact;
		contact.node1.other = body2;
		contact.node1.prev = null;
		contact.node1.next = body1.contactList;
		
		if (body1.contactList != null)
			body1.contactList.prev = contact.node1;
			
		body1.contactList = contact.node1;
		
		contact.node2.contact = contact;
		contact.node2.other = body1;
		contact.node2.prev = null;
		contact.node2.next = body2.contactList;
		
		if (body2.contactList != null)
			body2.contactList.prev = contact.node2;
		
		body2.contactList = contact.node2;
		
		body1.contactCount++;
		body2.contactCount++;
		
		world.contactCount++;
		return contact;
		
	}
	
	public function createContact(shape1:CollisionShape, shape2:CollisionShape):Contact
	{
		
		var type1:Int = shape1.shapeType;
		var type2:Int = shape2.shapeType;
		
		var i:Int;
		if (activeContactCount == poolSize)
		{
			var growSize:Int = 20;
			poolSize += growSize;
			
			var c1:Contact = contactPoolTail;
			var c2:Contact = contactPoolTail;
			
			var newContact:Contact;
			for (i in 0... growSize)
			{
				newContact = new Contact(null, null);
				c2.poolNext = newContact;
				newContact.poolPrev = c2;
				c2 = newContact;
			}
			
			contactPoolTail = c2;
			contactPoolTail.poolNext = contactPoolHead;
			contactPoolHead.poolPrev = contactPoolTail;
			allocationContact = c1.poolNext;
			
		}
		
		var contact:Contact = allocationContact;
		allocationContact = allocationContact.poolNext;
		
		activeContactCount++;
		
		if (type2 >= type1)
		{
			contact.init(shape1, shape2);
			return contact;
		}
		
		contact.init(shape2, shape1);
		for (m in contact.manifoldArray)
		{
			m.normal.x = -m.normal.x;
			m.normal.y = -m.normal.y;
		}
		return contact;
	}
	
	public function pairRemoved(contact:Contact):Void
	{
		if (contact == null || contact == nullContact)
			return;
		
		destroyContact(contact);
	}
	
	public function destroyContact(contact:Contact):Void
	{
		var shape1:CollisionShape = contact.shape1;
		var shape2:CollisionShape = contact.shape2;
		
		if (contact.prev != null)
			contact.prev.next = contact.next;
			
		if (contact.next != null)
			contact.next.prev = contact.prev;
			
		if (contact == world.contactList)
			world.contactList = contact.next;
			
		var body1:RigidBody = shape1.body;
		var body2:RigidBody = shape2.body;
		
		if (contact.node1.prev != null)
			contact.node1.prev.next = contact.node1.next;
			
		if (contact.node1.next != null)
			contact.node1.next.prev = contact.node1.prev;
			
		if (contact.node1 == body1.contactList)
			body1.contactList = contact.node1.next;
			
		
		if (contact.node2.prev != null)
			contact.node2.prev.next = contact.node2.next;
			
		if (contact.node2.next != null)
			contact.node2.next.prev = contact.node2.prev;
			
		if (contact.node2 == body2.contactList)
			body2.contactList = contact.node2.next;
			
		if (contact == contactPoolHead) {
			contactPoolHead = contactPoolHead.poolNext;
			contactPoolTail = contact;
		}else if (contact != contactPoolTail) {
			var p:Contact = contact.poolPrev;
			var n:Contact = contact.poolNext;
			n.poolPrev = p;
			p.poolNext = n;
			contact.poolPrev = contactPoolTail;
			contact.poolNext = contactPoolHead;
			contactPoolTail.poolNext = contact;
			contactPoolHead.poolPrev = contact;
			contactPoolTail = contact;
		}
		if (activeContactCount == poolSize) {
			allocationContact = contact;
		}
		
		body1.contactCount--;
		body2.contactCount--;
		
		world.contactCount--;
		activeContactCount--;
	}
	
}