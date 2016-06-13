/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.dynamics.RigidBody;

class CircleShape extends CollisionShape
{

	public var radius:Float;
	public var radiusSquared:Float;
	
	public function new(circleData:CircleDefinition, body:RigidBody) 
	{
		super(circleData, body);
		radius = circleData.radius;
		radiusSquared = radius * radius;
		shapeType = CollisionShape.CIRCLE_TYPE;
		position = new Vector2D();
		update();
		
	}
	
	override public function update():Void
	{
		var lx:Float = localPosition.x - body.localCenterOfMass.x;
		var ly:Float = localPosition.y - body.localCenterOfMass.y;
		
		position.x = body.worldCenterOfMass.x + body.orientation.i1j1 * lx + body.orientation.i1j2 * ly;
		position.y = body.worldCenterOfMass.y + body.orientation.i2j1 * lx + body.orientation.i2j2 * ly;
		
		updateAABB();

	}
	
	override public function updateAABB():Void
	{
		AABB.min.x = position.x - radius;
		AABB.min.y = position.y - radius;
		AABB.max.x = position.x + radius;
		AABB.max.y = position.y + radius;
	}
}