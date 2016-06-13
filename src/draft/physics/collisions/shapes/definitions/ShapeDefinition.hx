/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes.definitions;
import draft.math.Vector2D;
import draft.patterns.IObserver;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.Material;

class ShapeDefinition 
{
	private static var DEFAULT_MATERIAL:Material = new Material(1, 0, 0);
	
	public var localPosition:Vector2D;
	
	public var density:Float;
	public var area:Float;
	public var mass:Float;
	
	public var I:Float;
	public var centerOfMass:Vector2D;
	
	public var shapeType:Int;
	
	public var friction:Float;
	public var restitution:Float;
	
	public var next:ShapeDefinition;
	public var prev:ShapeDefinition;
	
	public var collisionCategory:Int;
	public var resolutionCategory:Int;
	public var collisionMask:Int;
	public var resolutionMask:Int;
	public var collisionGroup:Int;
	public var resolutionGroup:Int;
	
	public var observerArray:Array<IObserver>;
	
	public function new(?material:Material) 
	{
		if (material == null)
		{
			material = DEFAULT_MATERIAL;
		}
		
		collisionCategory = 1;
		resolutionCategory = 1;
		collisionMask = 0x0000FFFF;
		resolutionMask = 0x0000FFFF;
		collisionGroup = 0;
		resolutionGroup = 0;
		
		density = material.density;
		friction = material.friction;
		restitution = material.restitution;
		
		localPosition = new Vector2D();
		centerOfMass = new Vector2D();
		
		shapeType = CollisionShape.NO_TYPE;
		observerArray = new Array<IObserver>();
	}

	public function clone():ShapeDefinition
	{
		return null;
	}
	
	public function calculateMassInformation():Void
	{
		
	}
	
}