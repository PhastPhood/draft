/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.contacts;
import draft.math.MathApprox;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.CircleShape;
import draft.physics.dynamics.RigidBody;

class Manifold 
{

	public static inline var CIRCLE:Int = 0;
	public static inline var FACE_A:Int = 1;
	public static inline var FACE_B:Int = 2;
	
	public var body1:RigidBody;
	public var body2:RigidBody;
	
	public var pointCount:Int;
	public var normal:Vector2D;
	public var pointArray:Array<ContactPoint>;
	public var point1:ContactPoint;
	public var point2:ContactPoint;
	
	public var invMass1:Float;
	public var invMass2:Float;
	
	public var invI1:Float;
	public var invI2:Float;
	
	public var kN11:Float;
	public var kN12:Float;
	public var kN21:Float;
	public var kN22:Float;
	
	
	public var kE11:Float;
	public var kE12:Float;
	public var kE21:Float;
	public var kE22:Float;
	
	public var normalMass11:Float;
	public var normalMass12:Float;
	public var normalMass21:Float;
	public var normalMass22:Float;
	
	public var equalizedMass11:Float;
	public var equalizedMass12:Float;
	public var equalizedMass21:Float;
	public var equalizedMass22:Float;

	public var useSecondPoint:Bool;
	public var manifoldType:Int;
	
	public var localNormal:Vector2D;
	public var localPoint:Vector2D;
	
	
	public function new() 
	{
		normal = new Vector2D();
		pointArray = new Array<ContactPoint>();
		
		point1 = new ContactPoint();
		point2 = new ContactPoint();
		
		pointArray[0] = point1;
		pointArray[1] = point2;
		
		localNormal = new Vector2D();
		localPoint = new Vector2D();
	}
	
	public function reset():Void
	{
		body1 = null;
		body2 = null;
		
		pointCount = 0;
		normal.x = 0;
		normal.y = 0;
		
		invMass1 = 0;
		invMass2 = 0;
		invI1 = 0;
		invI2 = 0;
		
		kN11 = 0;
		kN21 = 0;
		kN12 = 0;
		kN22 = 0;
		
		normalMass11 = 0;
		normalMass12 = 0;
		normalMass21 = 0;
		normalMass22 = 0;
		
		equalizedMass11 = 0;
		equalizedMass12 = 0;
		equalizedMass21 = 0;
		equalizedMass22 = 0;
		
		useSecondPoint = false;
		manifoldType = 0;
		
		localNormal.x = 0;
		localNormal.y = 0;
		
		localPoint.x = 0;
		localPoint.y = 0;
		
		point1 = null;
		point2 = null;
		point1 = new ContactPoint();
		point2 = new ContactPoint();
		pointArray[0] = point1;
		pointArray[1] = point2;
	}
	
	public function reevaluate():Void
	{
		var orientation:RotationMatrix2D;
		var pointx:Float;
		var pointy:Float;
		
		var clipx:Float;
		var clipy:Float;
		
		var cp:ContactPoint;
		
		var dx:Float;
		var dy:Float;
		
		var lx:Float;
		var ly:Float;
		
		if (manifoldType == FACE_A) {
			lx = localPoint.x - body1.localCenterOfMass.x;
			ly = localPoint.y - body1.localCenterOfMass.y;
			orientation = body1.orientation;
			normal.x = orientation.i1j1 * localNormal.x + orientation.i1j2 * localNormal.y;
			normal.y = orientation.i2j1 * localNormal.x + orientation.i2j2 * localNormal.y;
			pointx = orientation.i1j1 * lx + orientation.i1j2 * ly + body1.worldCenterOfMass.x;
			pointy = orientation.i2j1 * lx + orientation.i2j2 * ly + body1.worldCenterOfMass.y;
			
			orientation = body2.orientation;
			if (pointCount == 1)
			{
				cp = useSecondPoint ? point2 : point1;
				lx = cp.localPoint.x - body2.localCenterOfMass.x;
				ly = cp.localPoint.y - body2.localCenterOfMass.y;
				clipx = orientation.i1j1 * lx + orientation.i1j2 * ly + body2.worldCenterOfMass.x;
				clipy = orientation.i2j1 * lx + orientation.i2j2 * ly + body2.worldCenterOfMass.y;
				dx = clipx - pointx;
				dy = clipy - pointy;
				cp.separation = dx * normal.x + dy * normal.y;
				cp.position.x = clipx;
				cp.position.y = clipy;				
			}else
			{

				for (i in 0...pointCount)
				{
					cp = pointArray[i];
					lx = cp.localPoint.x - body2.localCenterOfMass.x;
					ly = cp.localPoint.y - body2.localCenterOfMass.y;
					clipx = orientation.i1j1 * lx + orientation.i1j2 * ly + body2.worldCenterOfMass.x;
					clipy = orientation.i2j1 * lx + orientation.i2j2 * ly + body2.worldCenterOfMass.y;
					dx = clipx - pointx;
					dy = clipy - pointy;
					cp.separation = dx * normal.x + dy * normal.y;
					cp.position.x = clipx;
					cp.position.y = clipy;
				}
			}
			
		}else if (manifoldType == FACE_B) {
			lx = localPoint.x - body2.localCenterOfMass.x;
			ly = localPoint.y - body2.localCenterOfMass.y;
			
			orientation = body2.orientation;
			normal.x = orientation.i1j1 * localNormal.x + orientation.i1j2 * localNormal.y;
			normal.y = orientation.i2j1 * localNormal.x + orientation.i2j2 * localNormal.y;
			pointx = orientation.i1j1 * lx + orientation.i1j2 * ly + body2.worldCenterOfMass.x;
			pointy = orientation.i2j1 * lx + orientation.i2j2 * ly + body2.worldCenterOfMass.y;
			
			orientation = body1.orientation;
			if (pointCount == 1)
			{
				cp = useSecondPoint ? point2 : point1;
				lx = cp.localPoint.x - body1.localCenterOfMass.x;
				ly = cp.localPoint.y - body1.localCenterOfMass.y;
				clipx = orientation.i1j1 * lx + orientation.i1j2 * ly + body1.worldCenterOfMass.x;
				clipy = orientation.i2j1 * lx + orientation.i2j2 * ly + body1.worldCenterOfMass.y;
				dx = clipx - pointx;
				dy = clipy - pointy;
				cp.separation = dx * normal.x + dy * normal.y;
				cp.position.x = clipx;
				cp.position.y = clipy;				
			}else
			{
				for (i in 0...pointCount)
				{
					cp = pointArray[i];
					lx = cp.localPoint.x - body1.localCenterOfMass.x;
					ly = cp.localPoint.y - body1.localCenterOfMass.y;
					clipx = orientation.i1j1 * lx + orientation.i1j2 * ly + body1.worldCenterOfMass.x;
					clipy = orientation.i2j1 * lx + orientation.i2j2 * ly + body1.worldCenterOfMass.y;
					dx = clipx - pointx;
					dy = clipy - pointy;
					cp.separation = dx * normal.x + dy * normal.y;
					cp.position.x = clipx;
					cp.position.y = clipy;
				}
			}
			
			normal.x = -normal.x;
			normal.y = -normal.y;
			
		}else if (manifoldType == CIRCLE)
		{
			lx = localPoint.x - body1.localCenterOfMass.x;
			ly = localPoint.y - body1.localCenterOfMass.y;
			
			orientation = body1.orientation;
			
			var pAx:Float = orientation.i1j1 * lx + orientation.i1j2 * ly + body1.worldCenterOfMass.x;
			var pAy:Float = orientation.i2j1 * lx + orientation.i2j2 * ly + body1.worldCenterOfMass.y;
			
			lx = point1.localPoint.x - body2.localCenterOfMass.x;
			ly = point1.localPoint.y - body2.localCenterOfMass.y;
			orientation = body2.orientation;
			var pBx:Float = orientation.i1j1 * lx + orientation.i1j2 * ly + body2.worldCenterOfMass.x;
			var pBy:Float = orientation.i2j1 * lx + orientation.i2j2 * ly + body2.worldCenterOfMass.y;
			
			normal.x = pBx - pAx;
			normal.y = pBy - pAy;
			
			var d:Float = MathApprox.invSqrt(normal.x * normal.x + normal.y * normal.y);
			normal.x *= d;
			normal.y *= d;
			
			point1.position.x = (pAx + pBx) * 0.5;
			point1.position.y = (pAy + pBy) * 0.5;
			
			point1.separation = 1/d - (cast(point1.shape1, CircleShape)).radius - (cast(point1.shape2, CircleShape)).radius;
			
		}
	}
	
	
}