/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes.definitions;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.Material;

class CircleDefinition extends ShapeDefinition
{

	public var radius:Float;
	
	public function new(radius:Float, material:Material) 
	{
		super(material);
		this.radius = radius;
		calculateMassInformation();
		shapeType = CollisionShape.CIRCLE_TYPE;
	}
	
	override public function clone():ShapeDefinition
	{
		var cd:CircleDefinition = new CircleDefinition(radius, new Material(density, friction, restitution));
		cd.localPosition = localPosition.clone();
		cd.centerOfMass = centerOfMass.clone();
		cd.mass = mass;
		cd.area = area;
		cd.I = I;
		
		cd.collisionCategory = collisionCategory;
		cd.resolutionCategory = resolutionCategory;
		cd.collisionMask = collisionMask;
		cd.resolutionMask = resolutionMask;
		cd.collisionGroup = collisionGroup;
		cd.resolutionGroup = resolutionGroup;
		
		cd.observerArray = observerArray.copy();
		
		return cd;
	}
	
	override public function calculateMassInformation():Void
	{
		area = Math.PI * radius * radius;
		mass = density * area;
		I = 0.5 * mass * radius * radius;
	}
	
	
	
}