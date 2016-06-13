/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes.definitions;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.Material;

class RectangleDefinition extends ShapeDefinition
{
	public var width:Float;
	public var height:Float;
	public var localRotation:Float;
	
	public function new(width:Float, height:Float, material:Material ) 
	{
		super(material);
		this.width = width;
		this.height = height;
		calculateMassInformation();
		shapeType = CollisionShape.RECTANGLE_TYPE;
		localRotation = 0;
	}
	
	override public function clone():ShapeDefinition
	{
		var rd:RectangleDefinition = new RectangleDefinition(width, height, new Material(density, friction, restitution));
		rd.localPosition = localPosition.clone();
		rd.localRotation = localRotation;
		rd.centerOfMass = centerOfMass.clone();
		rd.mass = mass;
		rd.area = area;
		rd.I = I;
		
		rd.collisionCategory = collisionCategory;
		rd.resolutionCategory = resolutionCategory;
		rd.collisionMask = collisionMask;
		rd.resolutionMask = resolutionMask;
		rd.collisionGroup = collisionGroup;
		rd.resolutionGroup = resolutionGroup;
		
		rd.observerArray = observerArray.copy();
		
		return rd;
	}
	
	override public function calculateMassInformation():Void
	{
		area = width * height;
		mass = density * area;
		I = mass * (width * width + height * height) / 12;
	}
}