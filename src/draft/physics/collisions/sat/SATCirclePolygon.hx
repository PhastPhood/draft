/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.sat;
import draft.math.MathApprox;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.CircleShape;
import draft.physics.collisions.shapes.PolygonShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.dynamics.RigidBody;

class SATCirclePolygon 
{

	public function new() 
	{
		
	}
	
	public function collide(circle:CircleShape, polygon:PolygonShape, contact:Contact):Void
	{
		var m:Manifold = contact.manifold;
		m.manifoldType = Manifold.FACE_B;
		m.useSecondPoint = false;
		
		var cp:ContactPoint = m.point1;
		cp.localPoint.x = circle.localPosition.x;
		cp.localPoint.y = circle.localPosition.y;
		cp.id.referenceEdge = 0;
		cp.id.flip = 1;
		cp.id.incidentVertex = 31;
		
		var vertex1:Vector2D;
		var vertex2:Vector2D;
		var localVertex:Vector2D;
		var normal:Vector2D;
		var localNormal:Vector2D = new Vector2D();
		
		var lx:Float;
		var ly:Float;
		
		var dx:Float;
		var dy:Float;
		
		var pdx:Float = 0;
		var pdy:Float = 0;
		
		var cx:Float = circle.position.x;
		var cy:Float = circle.position.y;
		
		var projection:Float;
		
		var dSq:Float;
		var minDSq:Float = Math.POSITIVE_INFINITY;
		var minD:Float = 0;
		
		var corner:Bool = false;
		var incidentVertex:Int = 0;
		
		var body1:RigidBody = circle.body;
		var body2:RigidBody = polygon.body;
		
		var edge:Int = 0;
		
		for (i in 0...polygon.vertexCount)
		{
			vertex1 = polygon.worldVertexArray[i];
			vertex2 = vertex1.next;
			
			lx = vertex2.x - vertex1.x;
			ly = vertex2.y - vertex1.y;
			
			dx = cx - vertex1.x;
			dy = cy - vertex1.y;
			
			projection = dx * lx + dy * ly;
			
			if (projection < 0)
			{
				dSq = dx * dx + dy * dy;
				if (dSq < minDSq)
				{
					minDSq = dSq;
					pdx = dx;
					pdy = dy;
					
					corner = true;
					incidentVertex = i;
					
					continue;
				}else if (dSq == minDSq)
				{
					if (pdx == dx)
					{
						if (pdy == dy)
							break;
					}
				}
			}else if (projection > lx * lx + ly * ly)
			{
				dx = cx - vertex2.x;
				dy = cy - vertex2.y;
				dSq = dx * dx + dy * dy;
				
				if (dSq < minDSq)
				{
					minDSq = dSq;
					pdx = dx;
					pdy = dy;
					corner = true;
					incidentVertex = i == (polygon.vertexCount - 1) ? 0 : i + 1;
				}else if (dSq == minDSq)
				{
					if (pdx == dx)
					{
						if (pdy == dy)
							break;
					}
				}
			}else
			{
				normal = polygon.worldNormalArray[i];
				projection = normal.x * dx + normal.y * dy;
				
				if (projection > circle.radius)
				{
					m.pointCount = 0;
					return;
				}
				
				if (projection > 0)
				{
					m.pointCount = 1;
					cp.id.incidentEdge = i;
					cp.id.generateKey();
					
					cp.separation = projection - circle.radius;
					
					m.normal.x = -normal.x;
					m.normal.y = -normal.y;
					
					vertex1 = polygon.localVertexArray[i];
					vertex2 = vertex1.next;
					
					
					var o:RotationMatrix2D = polygon.localOrientation;
					
					dx = vertex1.x * o.i1j1 + vertex1.y * o.i1j2 + polygon.localPosition.x;
					dy = vertex1.x * o.i2j1 + vertex1.y * o.i2j2 + polygon.localPosition.y;
					lx = vertex2.x * o.i1j1 + vertex2.y * o.i1j2 + polygon.localPosition.x;
					ly = vertex2.x * o.i2j1 + vertex2.y * o.i2j2 + polygon.localPosition.y;
					
					m.localPoint.x = (dx + lx) * 0.5;
					m.localPoint.y = (dy + ly) * 0.5;
					
					lx = polygon.localNormalArray[i].x;
					ly = polygon.localNormalArray[i].y;
					
					m.localNormal.x = lx * o.i1j1 + ly * o.i1j2;
					m.localNormal.y = lx * o.i2j1 + ly * o.i2j2;
					
					cp.position.x = cx - normal.x * circle.radius;
					cp.position.y = cy - normal.y * circle.radius;
											
					cp.r1.x = cp.position.x - body1.worldCenterOfMass.x;
					cp.r1.y = cp.position.y - body1.worldCenterOfMass.y;
					cp.r2.x = cp.position.x - body2.worldCenterOfMass.x;
					cp.r2.y = cp.position.y - body2.worldCenterOfMass.y;
					
					o = body1.orientation;
					cp.localPoint.x = o.i1j1 * cp.r1.x + o.i2j1 * cp.r1.y + body1.localCenterOfMass.x;
					cp.localPoint.y = o.i1j2 * cp.r1.x + o.i2j2 * cp.r1.y + body1.localCenterOfMass.y;
					return;
				}
				
				dSq = projection * projection;
				if (dSq < minDSq)
				{
					minDSq = dSq;
					minD = circle.radius - projection;
					corner = false;
					edge = i;
					pdx = polygon.worldNormalArray[i].x;
					pdy = polygon.worldNormalArray[i].y;
					
					localNormal.x = polygon.localNormalArray[i].x;
					localNormal.y = polygon.localNormalArray[i].y;
				}
			}
		}
		
		if (corner)
		{
			if (minDSq > circle.radiusSquared)
			{
				m.pointCount = 0;
				return;
			}
			
			m.pointCount = 1;
			cp.id.incidentEdge = 31;
			cp.id.incidentVertex = incidentVertex;
			cp.id.generateKey();
			
			minD = MathApprox.invSqrt(minDSq);
			pdx *= minD;
			pdy *= minD;
			cp.separation = 1 / minD - circle.radius;
			m.normal.x = -pdx;
			m.normal.y = -pdy;
			
			var o:RotationMatrix2D = polygon.localOrientation;
			dx = polygon.localVertexArray[incidentVertex].x;
			dy = polygon.localVertexArray[incidentVertex].y;
			
			m.localPoint.x = dx * o.i1j1 + dy * o.i1j2 + polygon.localPosition.x;
			m.localPoint.y = dx * o.i2j1 + dy * o.i2j2 + polygon.localPosition.y;
			
			cp.position.x = cx - pdx * circle.radius;
			cp.position.y = cy - pdy * circle.radius;
			
			cp.r1.x = cp.position.x - body1.worldCenterOfMass.x;
			cp.r1.y = cp.position.y - body1.worldCenterOfMass.y;
			cp.r2.x = cp.position.x - body2.worldCenterOfMass.x;
			cp.r2.y = cp.position.y - body2.worldCenterOfMass.y;
			
			o = body1.orientation;
			cp.localPoint.x = o.i1j1 * cp.r1.x + o.i2j1 * cp.r1.y + body1.localCenterOfMass.x;
			cp.localPoint.y = o.i1j2 * cp.r1.x + o.i2j2 * cp.r1.y + body1.localCenterOfMass.y;
			
			return;			
			
		}
		
		m.pointCount = 1;
		cp.id.incidentEdge = edge;
		cp.id.generateKey();
		
		cp.separation = -minD;
		m.normal.x = -pdx;
		m.normal.y = -pdy;
		
		vertex1 = polygon.localVertexArray[edge];
		vertex2 = vertex1.next;
		
		var o:RotationMatrix2D = polygon.localOrientation;
		
		dx = vertex1.x * o.i1j1 + vertex1.y * o.i1j2 + polygon.localPosition.x;
		dy = vertex1.x * o.i2j1 + vertex1.y * o.i2j2 + polygon.localPosition.y;
		lx = vertex2.x * o.i1j1 + vertex2.y * o.i1j2 + polygon.localPosition.x;
		ly = vertex2.x * o.i2j1 + vertex2.y * o.i2j2 + polygon.localPosition.y;
		
		m.localPoint.x = (dx + lx) * 0.5;
		m.localPoint.y = (dy + ly) * 0.5;
		
		m.localNormal.x = localNormal.x * o.i1j1 + localNormal.y * o.i1j2;
		m.localNormal.y = localNormal.x * o.i2j1 + localNormal.y * o.i2j2;
		
		cp.position.x = cx - pdx * circle.radius;
		cp.position.y = cy - pdy * circle.radius;
		
		cp.r1.x = cp.position.x - body1.worldCenterOfMass.x;
		cp.r1.y = cp.position.y - body1.worldCenterOfMass.y;
		cp.r2.x = cp.position.x - body2.worldCenterOfMass.x;
		cp.r2.y = cp.position.y - body2.worldCenterOfMass.y;		
		
		
		o = body1.orientation;
		cp.localPoint.x = o.i1j1 * cp.r1.x + o.i2j1 * cp.r1.y + body1.localCenterOfMass.x;
		cp.localPoint.y = o.i1j2 * cp.r1.x + o.i2j2 * cp.r1.y + body1.localCenterOfMass.y;

	}
	
}