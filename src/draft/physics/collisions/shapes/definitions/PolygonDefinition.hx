/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes.definitions;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.Material;

class PolygonDefinition extends ShapeDefinition
{
	public var localVertexArray:Array<Vector2D>;
	public var localNormalArray:Array<Vector2D>;
	
	public var center:Vector2D;
	
	public var localRotation:Float;
	
	public function new(vertices:Array<Float>, material:Material) 
	{
		super(material);
		center = new Vector2D();
		localRotation = 0;
		shapeType = CollisionShape.POLYGON_TYPE;
		if (vertices == null)
			return;
		localVertexArray = new Array<Vector2D>();
		localNormalArray = new Array<Vector2D>();
		init(vertices);
	}
	
	private function init(v:Array<Float>):Void
	{
		
		for (a in localVertexArray)
		{
			a = null;
		}
		for (a in localNormalArray)
		{
			a = null;
		}
		
		var dX:Float;
		var dY:Float;
		var aLen:Float;
		
		var n:Int = Std.int(v.length / 2);
		
		var i1:Int;
		var i2:Int;
		
		for (i in 0...n) {
			i1 = i * 2;
			i2 = i < n - 1 ? i * 2 + 2 : 0;
			localVertexArray.push(new Vector2D(v[i1], v[i1 + 1]));
			dX = v[i2] - v[i1];
			dY = v[i2 + 1] - v[i1 + 1];
			aLen = Math.sqrt(dX * dX + dY * dY);
			dX /= aLen;
			dY /= aLen;
			localNormalArray.push(new Vector2D(-dY, dX));
		}
		
		calculateMassInformation();
	}
	
	override public function calculateMassInformation():Void
	{
		area = 0;
		I = 0;
		
		centerOfMass.x = 0;
		centerOfMass.y = 0;
		
		var x0:Float;
		var y0:Float;
		var x1:Float;
		var y1:Float;
		
		var pp:Float;
		
		var j:Int;
		var n:Int = localVertexArray.length;
		
		var intx2:Float;
		var inty2:Float;
		
		for (i in 0...n) {
			j = i + 1 != n ? i + 1 : 0;
			
			x0 = localVertexArray[i].x;
			y0 = localVertexArray[i].y;
			x1 = localVertexArray[j].x;
			y1 = localVertexArray[j].y;
			
			pp = x0 * y1 - x1 * y0;
			area += pp;
			centerOfMass.x += (x0 + x1) * pp;
			centerOfMass.y += (y0 + y1) * pp;
			
			intx2 = (x0 * x0 + x1 * x0 + x1 * x1) / 12;
			inty2 = (y0 * y0 + y1 * y0 + y1 * y1) / 12;
			I += pp * (intx2 + inty2);
		}

		area *= 0.5;
		var t:Float = 1 / (area * 6);
		centerOfMass.x *= t;
		centerOfMass.y *= t;
	   
		center.x = centerOfMass.x;
		center.y = centerOfMass.y;
	   
		area = area < 0 ? -area : area;
		mass = density * area;
	   
		I = density * (I - area * (centerOfMass.x * centerOfMass.x + centerOfMass.y * centerOfMass.y));
		I = I < 0 ? -I : I;
	}
	
	override public function clone():ShapeDefinition
	{
		var va:Array<Vector2D> = new Array<Vector2D>();
		var na:Array<Vector2D> = new Array<Vector2D>();
		for (v in localVertexArray)
		{
			va.push(v.clone());
		}
		for (v in localNormalArray)
		{
			na.push(v.clone());
		}
		var c:PolygonDefinition = new PolygonDefinition(null, new Material(density, friction, restitution));
		c.localVertexArray = va;
		c.localNormalArray = na;
		c.center = center.clone();
		c.centerOfMass = centerOfMass.clone();
		c.I = I;
		c.mass = mass;
		c.localPosition = localPosition.clone();
		c.localRotation = localRotation;
		c.area = area;
		
		c.collisionCategory = collisionCategory;
		c.resolutionCategory = resolutionCategory;
		c.collisionMask = collisionMask;
		c.resolutionMask = resolutionMask;
		c.collisionGroup = collisionGroup;
		c.resolutionGroup = resolutionGroup;
		
		c.observerArray = observerArray.copy();
		
		return c;
	}
	
}