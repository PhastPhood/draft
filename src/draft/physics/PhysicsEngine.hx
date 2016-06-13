/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics;
import draft.physics.collisions.broadphase.strategies.BruteForce;
import draft.physics.collisions.broadphase.strategies.IBroadPhase;
import draft.physics.collisions.broadphase.strategies.SpatialHash;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactManager;
import draft.physics.dynamics.contacts.ContactNode;
import draft.physics.dynamics.forces.ForceGenerator;
import draft.physics.dynamics.forces.ForceGeneratorNode;
import draft.physics.dynamics.Island;
import draft.physics.dynamics.RigidBody;
import draft.physics.dynamics.RigidBodyDefinition;

class PhysicsEngine 
{
	public var bodyList:RigidBody;
	public var bodyCount:Int;
	public var bodyArray:Array<RigidBody>;
	
	public var contactList:Contact;
	public var contactCount:Int;
	
	public var contactManager:ContactManager;
	public var island:Island;
	
	public var forceList:ForceGeneratorNode;
	
	public var broadPhase:IBroadPhase;
	
	public var shapeArray:Array<CollisionShape>;
	
	public var stepIndex:Int;
	
	private var _stack:Array<RigidBody>;
	public function new() 
	{
		contactManager = new ContactManager(this);
		
		bodyArray = new Array<RigidBody>();
		shapeArray = new Array<CollisionShape>();
		island = new Island();
		
		broadPhase = new SpatialHash();
		broadPhase.setContactManager(contactManager);
		
		_stack = new Array<RigidBody>();
	}
	
	public function addBody(bodyData:RigidBodyDefinition):RigidBody
	{
		var body:RigidBody = new RigidBody(bodyData, this);
		
		var shape1:CollisionShape = body.shapeList;
		for (i in 0...body.shapeCount)
		{
			broadPhase.createProxy(shape1);
			shape1 = shape1.next;
		}
		
		bodyArray.push(body);
		
		if (bodyList == null)
		{
			bodyList = body;
			bodyList.prev = bodyList;
			bodyList.next = bodyList;
			bodyCount++;
			return body;
		}
		body.prev = bodyList.prev;
		bodyList.prev.next = body;
		body.next = bodyList;
		bodyList.prev = body;
		
		bodyCount++;
		
		return body;
	}
	
	public function removeBody(body:RigidBody):Void
	{
		body.free();
	}
	
	
	public function step(overallDt:Float, iterations:Int, stepCount:Int):Void
	{
		stepIndex = 0;
		var dt:Float = overallDt / stepCount;
		for (st in 0...stepCount)
		{
			contactManager.collide();
			
			var body:RigidBody;
			var contact:Contact = contactList;
			
			for (i in 0...contactCount) {
				contact.islandFlag = false;
				contact = contact.next;
			}
			
			var stackSize:Int = 0;
			//var stack:Array<RigidBody> = new Array<RigidBody>();
			var other:RigidBody;
			var contactNode:ContactNode;
			
			for (seed in bodyArray) {
				if (seed.isStatic)
					continue;
				if(seed.islandFlag)
					continue;
				if(seed.isSleeping)
					continue;
				island.reset();
				_stack[0] = seed;
				stackSize = 1;
				seed.islandFlag = true;
				while (stackSize > 0) {
					stackSize--;
					body = _stack[stackSize];
					island.bodyArray[island.bodyCount] = body;
					island.bodyCount++;
					body.wakeUp();
					if (body.isStatic)
						continue;
						
					contactNode = body.contactList;
					while (contactNode != null)
					{
						if (contactNode.contact.islandFlag)
						{
							contactNode = contactNode.next;
							continue;
						}
						if (contactNode.contact.manifoldCount == 0)
						{
							contactNode = contactNode.next;
							continue;
						}
						island.contactArray[island.contactCount] = contactNode.contact;
						island.contactCount++;
						contactNode.contact.islandFlag = true;
						
						other = contactNode.other;
						if (other.islandFlag)
						{
							contactNode = contactNode.next;
							continue;
						}
						_stack[stackSize] = other;
						stackSize++;
						other.islandFlag = true;
						contactNode = contactNode.next;
					}
				}
				island.solve(dt, iterations);
				
				
				for (i in 0...island.bodyCount)
				{
					body = island.bodyArray[i];
					if (body.isStatic)
						body.islandFlag = false;
				}
			}
			
			for (body in bodyArray) {
				if (body.isStatic)
					continue;
				body.synchronizeShapes();
				body.islandFlag = false;
			}
			
			broadPhase.commit();
			stepIndex++;
		}
	}
	
	
	public function addWorldForce(force:ForceGenerator):Void
	{
		force.bodyArray = bodyArray;
		force.updateForce();
		var fN:ForceGeneratorNode = new ForceGeneratorNode(force);
		if (forceList == null)
		{
			forceList = fN;
			return;
		}
		forceList.prev = fN;
		fN.next = forceList;
		forceList = fN;
	}
}