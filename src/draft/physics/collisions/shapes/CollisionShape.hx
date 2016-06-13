/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes;
import draft.math.AABB2D;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.broadphase.CollisionShapeProxy;
import draft.physics.collisions.CollisionNotifier;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.collisions.shapes.definitions.PolygonDefinition;
import draft.physics.collisions.shapes.definitions.RectangleDefinition;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.RigidBody;


class CollisionShape 
{
	
	public static inline var CIRCLE_TYPE = 1;
	public static inline var RECTANGLE_TYPE = 2;
	public static inline var POLYGON_TYPE = 3;
	public static inline var AABB_TYPE = 4;
	
	public static inline var NO_TYPE = 0;


	public static inline var NUM_SHAPE_TYPES = 4;
	public var body:RigidBody;
	
	public var shapeType:Int;
	
	public var AABB:AABB2D;
	
	public var localPosition:Vector2D;
	public var position:Vector2D;
	
	public var friction:Float;
	public var restitution:Float;
	
	public var prev:CollisionShape;
	public var next:CollisionShape;
	
	public var collisionCategory:Int;
	public var resolutionCategory:Int;
	public var collisionGroup:Int;
	public var resolutionGroup:Int;
	public var collisionMask:Int;
	public var resolutionMask:Int;
	
	public var proxyID:Int;
	
	public var enableNotifications:Bool;
	public var notifier:CollisionNotifier;
	
	public var data:Dynamic;
	
	public function new(shapeDef:ShapeDefinition, body:RigidBody) 
	{
		position = new Vector2D();
		localPosition = shapeDef.localPosition.clone();
		
		friction = shapeDef.friction;
		restitution = shapeDef.restitution;
		this.body = body;
		
		AABB = new AABB2D();
		
		collisionCategory = shapeDef.collisionCategory;
		resolutionCategory = shapeDef.resolutionCategory;
		collisionMask = shapeDef.collisionMask;
		resolutionMask = shapeDef.resolutionMask;
		collisionGroup = shapeDef.collisionGroup;
		resolutionGroup = shapeDef.resolutionGroup;
		
		proxyID = CollisionShapeProxy.NULL_PROXY;
		notifier = new CollisionNotifier(this);
		
		for (o in shapeDef.observerArray)
		{
			notifier.attach(o);
		}
		
		enableNotifications = false;
	}
	
	public function update():Void
	{
		
	}
	
	public function updateAABB():Void
	{
		
	}
	
	public static function getShapeClass(type:Int):Class<Dynamic>
	{
		if (type == 1)
			return CircleShape;
		else if (type == 2)
			return RectangleShape;
		else if (type == 3)
			return PolygonShape;
		return CollisionShape;
	}
	
	public static function getShapeDefinitionClass(type:Int):Class<Dynamic>
	{
		if (type == 1)
			return CircleDefinition;
		else if (type == 2)
			return RectangleDefinition;
		else if (type == 3)
			return PolygonDefinition;
		return ShapeDefinition;
	}
	
	public function free():Void
	{
		if (proxyID != CollisionShapeProxy.NULL_PROXY)
		{
			body.world.broadPhase.removeProxy(proxyID);
			proxyID = CollisionShapeProxy.NULL_PROXY;
		}
		
		if (notifier != null)
			notifier.free();
		
		if (prev != null)
			prev.next = next;
		if (next != null)
			next.prev = prev;
		
		body = null;
		
		localPosition = null;
		position = null;
		
		AABB = null;
		
		prev = null;
		next = null;
	}
	
}