/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;

class RigidBodyDefinition 
{

	public var position:Vector2D;
	public var rotation:Float;

	public var centerOfMass:Vector2D;
	public var mass:Float;
	public var I:Float;
	
	public var shapeList:ShapeDefinition;
	public var shapeCount:Int;
	
	public var allowSleep:Bool;
	
	public function new() 
	{
		allowSleep = true;
		centerOfMass = new Vector2D();
		position = new Vector2D();
		
		rotation = 0;
	}
	
	public function clone():RigidBodyDefinition
	{
		var c:RigidBodyDefinition = new RigidBodyDefinition();
		var walker:ShapeDefinition = shapeList;
		for (i in 0...shapeCount)
		{
			c.addShape(walker);
			walker = walker.next;
		}
		
		c.position.x = position.x;
		c.position.y = position.y;
		
		c.I = I;
		c.rotation = rotation;
		c.mass = mass;
		
		c.centerOfMass.x = centerOfMass.x;
		c.centerOfMass.y = centerOfMass.y;
		
		c.allowSleep = allowSleep;
		return c;
	}
	
	public function addShape(definition:ShapeDefinition):ShapeDefinition
	{
		var clone:ShapeDefinition = definition.clone();
		if (shapeList == null)
		{
			shapeCount = 1;
			shapeList = clone;
			shapeList.next = shapeList;
			shapeList.prev = shapeList;
			calculateInformation();
			return clone;
		}
		
		clone.prev = shapeList.prev;
		shapeList.prev.next = clone;
		clone.next = shapeList;
		shapeList.prev = clone;
		
		shapeCount++;
		calculateInformation();
		return clone;
	}
	
	public function calculateInformation():Void 
	{
		if (shapeCount == 1) {
			mass = shapeList.mass;
			if (mass == Math.POSITIVE_INFINITY)
				mass = 0;
				
			centerOfMass = shapeList.centerOfMass.clone();
			centerOfMass.x += shapeList.localPosition.x;
			centerOfMass.y += shapeList.localPosition.y;
			
			I = shapeList.I;
			if (I == Math.POSITIVE_INFINITY)
				I = 0;
			return;
		}
		
		var m:Float = 0;
		var moi:Float = 0;
		var cmx:Float = 0;
		var cmy:Float = 0;
		var shape:ShapeDefinition;
		var n:Int = shapeCount;
		
		var scmx:Float;
		var scmy:Float;
		var r:Float;
		var r11:Float;
		var r12:Float;
		var r21:Float;
		var r22:Float;
		
		var walker:ShapeDefinition = shapeList;
		for (i in 0...n) {
			m += walker.mass;
			moi += walker.I;
			scmx = walker.centerOfMass.x;
			scmy = walker.centerOfMass.y;
			cmx += (scmx + walker.localPosition.x) * walker.mass;
			cmy += (scmy + walker.localPosition.y) * walker.mass;
			
			walker = walker.next;
		}
		
		if (m > 0) {
			if (m == Math.POSITIVE_INFINITY) {
				m = 0;
				moi = 0;
				cmx = 0;
				cmy = 0;
			}else {
				cmx /= m;
				cmy /= m;
			}
		}else { 
			m = 0;
			moi = 0;
			cmx = 0;
			cmy = 0;
		}
		
		var rx:Float;
		var ry:Float;
		
		walker = shapeList;
		for (i in 0...n) {
			scmx = walker.centerOfMass.x;
			scmy = walker.centerOfMass.y;
			rx = walker.localPosition.x + scmx - cmx;
			ry = walker.localPosition.y + scmy - cmy;
			moi += walker.mass * (rx * rx + ry * ry);
			
			walker = walker.next;
		}
		
		centerOfMass.x = cmx;
		centerOfMass.y = cmy;
		
		if (I == Math.POSITIVE_INFINITY)
			I = 0;
			
		if (mass == Math.POSITIVE_INFINITY)
			mass = 0;
	}

	
}