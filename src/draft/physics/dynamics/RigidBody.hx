/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics;
import draft.math.MathApprox;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.contacts.ContactNode;
import draft.physics.dynamics.forces.ForceGenerator;
import draft.physics.dynamics.forces.ForceGeneratorNode;
import draft.physics.PhysicsEngine;
import flash.Vector;

class RigidBody 
{

	public var prev:RigidBody;
	public var next:RigidBody;
	
	public var world:PhysicsEngine;
	
	public var localCenterOfMass:Vector2D;
	public var worldCenterOfMass:Vector2D;
	public var position:Vector2D;
	
	public var velocity:Vector2D;
	public var mass:Float;
	public var invMass:Float;
	
	public var orientation:RotationMatrix2D;
	public var angularVelocity:Float;
	public var I:Float;
	public var invI:Float;
	
	public var accumulatedForce:Vector2D;
	public var accumulatedTorque:Float;
	public var forceGenerators:ForceGeneratorNode;
	
	public var shapeList:CollisionShape;
	public var shapeCount:Int;
	public var contactList:ContactNode;
	public var contactCount:Int;
	
	public var allowSleep:Bool;
	public var isSleeping:Bool;
	public var sleepTime:Float;
	public var minSeparation:Float;
	public var isStatic:Bool;
	public var islandFlag:Bool;
	
	public var data:Dynamic;
	
	
	public function new(definition:RigidBodyDefinition, world:PhysicsEngine) 
	{
		isSleeping = false;
		islandFlag = false;
		
		contactCount = 0;
		sleepTime = 0;
		
		position = new Vector2D();
		
		allowSleep = definition.allowSleep;
		
		this.world = world;
		
		velocity = new Vector2D();
		accumulatedForce = new Vector2D();
		accumulatedTorque = 0;
		
		worldCenterOfMass = new Vector2D();
		localCenterOfMass = definition.centerOfMass.clone();
		position = definition.position.clone();
		orientation = new RotationMatrix2D(definition.rotation);
		
		angularVelocity = 0;
		
		if (definition.mass == 0 || definition.mass == Math.POSITIVE_INFINITY)
		{
			mass = 0;
			invMass = 0;
			isStatic = true;
		}
		else
		{
			isStatic = false;
			mass = definition.mass;
			invMass = 1 / definition.mass;
			
		}
		
		if (definition.I == 0 || definition.I == Math.POSITIVE_INFINITY)
		{
			I = 0;
			invI = 0;
		}
		else
		{
			isStatic = false;
			I = definition.I;
			invI = 1 / I;
		}
		
		if (isStatic)
		{
			localCenterOfMass.x = 0;
			localCenterOfMass.y = 0;
		}
		
		worldCenterOfMass.x = position.x + localCenterOfMass.x;
		worldCenterOfMass.y = position.y + localCenterOfMass.y;
		
		var shapeDef:ShapeDefinition;
		var shapeClass:Class<Dynamic>;
		shapeCount = definition.shapeCount;
		
		var newShape:CollisionShape;
		shapeDef = definition.shapeList;
		
		for (i in 0...shapeCount)
		{
			shapeClass = CollisionShape.getShapeClass(shapeDef.shapeType);
			newShape = Type.createInstance(shapeClass, [shapeDef, this]);
			//append new shape to end of list
			if (shapeList == null)
			{
				shapeList = newShape;
				shapeList.next = shapeList;
				shapeList.prev = shapeList;
			}else
			{
				newShape.prev = shapeList.prev;
				shapeList.prev.next = newShape;
				newShape.next = shapeList;
				shapeList.prev = newShape;
			}
			shapeDef = shapeDef.next;
			
		}
		
		synchronizeTransform();
		synchronizeShapes();
	}
	
	public inline function synchronizeTransform():Void
	{
		worldCenterOfMass.x = position.x + localCenterOfMass.x;
		worldCenterOfMass.y = position.y + localCenterOfMass.y;
		
		if (I != 0)
		{
			
			var sin:Float = MathApprox.sin(orientation.angle);
			var cos:Float = MathApprox.cos(orientation.angle);
			
			orientation.i1j1 = cos;
			orientation.i2j1 = sin;
			orientation.i1j2 = -sin;
			orientation.i2j2 = cos;
		}
	}
	
	public inline function synchronizeShapes():Void
	{
		var walker:CollisionShape = shapeList;
		for (i in 0... shapeCount)
		{
			walker.update();
			walker = walker.next;
		}
	}
	
	public inline function applyForce(force:Vector2D):Void
	{
		accumulatedForce.x += force.x;
		accumulatedForce.y += force.y;
	}
	
	public inline function applyForceAtPoint(force:Vector2D, point:Vector2D):Void
	{
		accumulatedForce.x += force.x;
		accumulatedForce.y += force.y;
		accumulatedTorque += (point.x - worldCenterOfMass.x) * force.y - (point.y - worldCenterOfMass.y) * force.x;
	
	}
	
	public inline function applyImpulseAtPoint(impulse:Vector2D, point:Vector2D):Void 
	{
		velocity.x += impulse.x * invMass;
		velocity.y += impulse.y * invMass;
		angularVelocity += ((point.x - worldCenterOfMass.x) * impulse.y - (point.y - worldCenterOfMass.y) * impulse.x) * invI;
	}

	public inline function applyTorque(torque:Float):Void 
	{
		accumulatedTorque += torque;
	}
	
	public inline function putToSleep():Void
	{
		if (!isSleeping && allowSleep && world.island.allowSleep)
		{
			isSleeping = true;
			velocity.x = 0;
			velocity.y = 0;
			angularVelocity = 0;
			accumulatedForce.x = 0;
			accumulatedForce.y = 0;
			accumulatedTorque = 0;
			sleepTime = 0;
		}
	}
	
	public inline function accumulateForces():Void
	{
		if (!isStatic)
		{
			var fN:ForceGeneratorNode = world.forceList;
			while (true)
			{
				if (fN == null)
					break;
				fN.force.applyForce(this);
				fN = fN.next;
			}
			fN = forceGenerators;
			while (true)
			{
				if (fN == null)
					break;
				fN.force.applyForce(this);
				fN = fN.next;
			}
		}
		
	}
	
	public inline function clearForces():Void
	{
		accumulatedForce.x = 0;
		accumulatedForce.y = 0;
		accumulatedTorque = 0;
	}
	
	public function addForceGenerator(fG:ForceGenerator):ForceGeneratorNode
	{
		if (forceGenerators == null)
		{
			forceGenerators = new ForceGeneratorNode(fG);
			return forceGenerators;
		}
		
		var fGN:ForceGeneratorNode = new ForceGeneratorNode(fG);
		fGN.next = forceGenerators;
		forceGenerators.prev = fGN;
		forceGenerators = fGN;
		return fGN;
	}
	
	
	public inline function wakeUp():Void
	{
		if (isSleeping)
		{
			isSleeping = false;
			sleepTime = 0;
		}
	}
	
	public inline function getRotation():Float
	{
		return orientation.angle;
	}

	public function setRotation(value:Float):Void
	{
		value %= 6.283185307179586;
		orientation.setAngle(value);
	}
	
	public function forceUpdate(force:ForceGenerator):Void
	{
		wakeUp();
	}
	
	public function free():Void
	{
		if (world != null)
		{
			world.bodyCount--;
			world.bodyArray.remove(this);
		}
		if (prev != null)
			prev.next = next;
		if (next != null)
			next.prev = prev;
		var contact:ContactNode = contactList;
		var c:ContactNode;
		if (contact != null)
		{
			while (contact.next != null)
			{
				c = contact;
				contact = contact.next;
				world.contactManager.destroyContact(c.contact);
			}
		}
		
		var s:CollisionShape = shapeList;
		var s0:CollisionShape;
		
		if (s != null)
		{
			while (s.next != null)
			{
				s0 = s;
				s = s.next;
				s0.free();
			}
		}
		
		shapeList = null;
		contactList = null;
		prev = null;
		next = null;
		
		var f:ForceGeneratorNode = forceGenerators;
		var f0:ForceGeneratorNode;
		
		if (f != null)
		{
			while (f.next != null)
			{
				f0 = f;
				f = f.next;
				f0.force.removeBody(this);
				f0.free();
			}
		}
		
		world = null;
		accumulatedForce = null;
		position = null;
		velocity = null;
		worldCenterOfMass = null;
		localCenterOfMass = null;
		orientation = null;
	}
}