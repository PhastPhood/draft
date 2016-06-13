/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.sat;
import draft.math.MathApprox;
import draft.physics.collisions.ICollisionHandler;
import draft.physics.collisions.shapes.CircleShape;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.collisions.shapes.RectangleShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;

class SATCircleRectangle
{

	public function new() 
	{
		
	}
	
	public function collide(circle:CircleShape, rectangle:RectangleShape, contact:Contact):Void
	{
		var manifold:Manifold = contact.manifold;
		manifold.manifoldType = Manifold.FACE_B;
		
		var cp:ContactPoint = manifold.point1;
		cp.id.referenceEdge = 0;
		cp.id.flip = 1;
		cp.id.incidentVertex = 31;

		var corner:Bool = false;
		//dx and dy
		var dx:Float = circle.position.x - rectangle.position.x;
		var dy:Float = circle.position.y - rectangle.position.y;
		
		var r11:Float = rectangle.orientation.i1j1;
		var r12:Float = rectangle.orientation.i1j2;
		var r21:Float = rectangle.orientation.i2j1;
		var r22:Float = rectangle.orientation.i2j2;
		
		//circle's position in rectangle's space
		var lx:Float = dx * r11 - dy * r12;
		var ly:Float = -dx * r21 + dy * r22;
		
		//closest point
		var cx:Float;
		var cy:Float;
		
		//circle's position relative to corner position
		var px:Float = 0;
		var py:Float;
		
		//distance to closest point
		var d:Float = 0;
		var d1:Float;
		
		manifold.pointCount = 1;
		
		//world normals
		//local normals
		/*
		 * 	  V2 |	E1	 | V1
		 *    ___|_______|____
		 *		 |		 |
		 * 	  E2 |		 | E0
		 * 	  ___|_______|____
		 *       |       |
		 * 	  V3 |	E3   | V0
		 */
		
		if (lx > rectangle.halfWidth)
		{
			cx = rectangle.halfWidth;
			if (ly > rectangle.halfHeight)
			{
				cy = rectangle.halfHeight;
				cp.id.incidentVertex = 0;
				corner = true;
			}else if (ly < -rectangle.halfHeight)
			{
				cy = -rectangle.halfHeight;
				cp.id.incidentVertex = 1;
				corner = true;
			}else
			{
				cy = ly;
				d = lx - cx;
				if (d > circle.radius)
				{
					manifold.pointCount = 0;
					return;
				}
				cp.id.incidentEdge = 0;
				manifold.localNormal.x = rectangle.localOrientation.i1j1;
				manifold.localNormal.y = rectangle.localOrientation.i2j1;
				manifold.localPoint.x = manifold.localNormal.x * rectangle.halfWidth + rectangle.localPosition.x;
				manifold.localPoint.y = manifold.localNormal.y * rectangle.halfWidth + rectangle.localPosition.y;
				manifold.normal.x = -r11;
				manifold.normal.y = r12;
			}
		}else if (lx < -rectangle.halfWidth)
		{
			cx = -rectangle.halfWidth;
			if (ly > rectangle.halfHeight)
			{
				cy = rectangle.halfHeight;
				cp.id.incidentVertex = 3;
				corner = true;
			}else if (ly < -rectangle.halfHeight)
			{
				cy = -rectangle.halfHeight;
				cp.id.incidentVertex = 2;
				corner = true;
			}else
			{
				cy = ly;
				d = cx - lx;
				
				if (d > circle.radius)
				{
					manifold.pointCount = 0;
					return;
				}
				
				cp.id.incidentEdge = 2;
				manifold.localNormal.x = -rectangle.localOrientation.i1j1;
				manifold.localNormal.y = rectangle.localOrientation.i1j2;
				manifold.localPoint.x = manifold.localNormal.x * rectangle.halfWidth + rectangle.localPosition.x;
				manifold.localPoint.y = manifold.localNormal.y * rectangle.halfWidth + rectangle.localPosition.y;
				manifold.normal.x = r11;
				manifold.normal.y = r21;
			}			
		}else
		{
			if (ly > rectangle.halfHeight)
			{
				cy = rectangle.halfHeight;
				cx = lx;
				d = ly - cy;
				if (d > circle.radius)
				{
					manifold.pointCount = 0;
					return;
				}
				cp.id.incidentEdge = 3;
				manifold.localNormal.x = rectangle.localOrientation.i1j2;
				manifold.localNormal.y = rectangle.localOrientation.i1j1;
				manifold.localPoint.x = manifold.localNormal.x * rectangle.halfHeight + rectangle.localPosition.x;
				manifold.localPoint.y = manifold.localNormal.y * rectangle.halfHeight + rectangle.localPosition.y;
				manifold.normal.x = r21;
				manifold.normal.y = -r11;
			}else if (ly < -rectangle.halfHeight)
			{
				cy = -rectangle.halfHeight;
				cx = lx;
				d = cy - ly;
				if (d > circle.radius)
				{
					manifold.pointCount = 0;
					return;
				}
				cp.id.incidentEdge = 1;
				manifold.localNormal.x = rectangle.localOrientation.i2j1;
				manifold.localNormal.y = -rectangle.localOrientation.i1j1;
				manifold.localPoint.x = manifold.localNormal.x * rectangle.halfHeight + rectangle.localPosition.x;
				manifold.localPoint.y = manifold.localNormal.y * rectangle.halfHeight + rectangle.localPosition.y;
				manifold.normal.x = r12;
				manifold.normal.y = r11;
			}else
			{
				//center of circle is inside rectangle... ughh
				if (lx > 0)
				{
					d = lx - rectangle.halfWidth;
					if (ly > 0)
					{
						d1 = ly - rectangle.halfHeight;
						
						if (d > d1)
						{
							cy = ly;
							cx = rectangle.halfWidth;
							cp.id.incidentEdge = 0;
							manifold.localNormal.x = rectangle.localOrientation.i1j1;
							manifold.localNormal.y = rectangle.localOrientation.i2j1;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfWidth + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfWidth + rectangle.localPosition.y;
							manifold.normal.x = -r11;
							manifold.normal.y = r12;
						}else
						{
							d = d1;
							cx = lx;
							cy = rectangle.halfHeight;
							cp.id.incidentEdge = 3;
							manifold.localNormal.x = rectangle.localOrientation.i1j2;
							manifold.localNormal.y = rectangle.localOrientation.i1j1;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfHeight + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfHeight + rectangle.localPosition.y;
							manifold.normal.x = r21;
							manifold.normal.y = -r11;
						}
					}else
					{
						d1 = -ly - rectangle.halfHeight;
						if (d > d1)
						{
							cy = ly;
							cx = rectangle.halfWidth;
							cp.id.incidentEdge = 0;
							manifold.localNormal.x = rectangle.localOrientation.i1j1;
							manifold.localNormal.y = rectangle.localOrientation.i2j1;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfWidth + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfWidth + rectangle.localPosition.y;							manifold.normal.x = -r11;
							manifold.normal.y = r12;
						}else
						{
							d = d1;
							cx = lx;
							cy = -rectangle.halfHeight;
							cp.id.incidentEdge = 1;
							manifold.localNormal.x = rectangle.localOrientation.i2j1;
							manifold.localNormal.y = -rectangle.localOrientation.i1j1;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfHeight + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfHeight + rectangle.localPosition.y;
							manifold.normal.x = r12;
							manifold.normal.y = r11;
						}
					}
				}else
				{
					d = -lx - rectangle.halfWidth;
					if (ly > 0)
					{
						d1 = ly - rectangle.halfHeight;
						if (d > d1)
						{
							cy = ly;
							cx = -rectangle.halfWidth;
							cp.id.incidentEdge = 2;
							manifold.localNormal.x = -rectangle.localOrientation.i1j1;
							manifold.localNormal.y = rectangle.localOrientation.i1j2;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfWidth + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfWidth + rectangle.localPosition.y;
							manifold.normal.x = r11;
							manifold.normal.y = r21;
						}else
						{
							d = d1;
							cx = lx;
							cy = rectangle.halfHeight;
							cp.id.incidentEdge = 3;
							manifold.localNormal.x = rectangle.localOrientation.i1j2;
							manifold.localNormal.y = rectangle.localOrientation.i1j1;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfHeight + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfHeight + rectangle.localPosition.y;
							manifold.normal.x = r21;
							manifold.normal.y = -r11;
						}
					}else
					{
						d1 = -ly - rectangle.halfHeight;
						if (d > d1)
						{
							cy = ly;
							cx = -rectangle.halfWidth;
							cp.id.incidentEdge = 2;
							manifold.localNormal.x = -rectangle.localOrientation.i1j1;
							manifold.localNormal.y = rectangle.localOrientation.i1j2;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfWidth + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfWidth + rectangle.localPosition.y;
							manifold.normal.x = r11;
							manifold.normal.y = r21;
						}else
						{
							d = d1;
							cx = lx;
							cy = -rectangle.halfHeight;
							cp.id.incidentEdge = 1;
							manifold.localNormal.x = rectangle.localOrientation.i2j1;
							manifold.localNormal.y = -rectangle.localOrientation.i1j1;
							manifold.localPoint.x = manifold.localNormal.x * rectangle.halfHeight + rectangle.localPosition.x;
							manifold.localPoint.y = manifold.localNormal.y * rectangle.halfHeight + rectangle.localPosition.y;
							manifold.normal.x = r12;
							manifold.normal.y = r11;
						}
					}
				}
			}
		}
		if (corner)
		{
			px = lx - cx;
			py = ly - cy;
			d = px * px + py * py;
			if (d > circle.radiusSquared)
			{
				manifold.pointCount = 0;
				return;
			}
			cp.id.incidentEdge = 31;

			d = MathApprox.invSqrt(d);
			
			px *= d;
			py *= d;
			
			d = 1 / d;
			
			//manifold.localNormal.x = px;
			//manifold.localNormal.y = py;
			
			
			manifold.localNormal.x = px * rectangle.localOrientation.i1j1 + py * rectangle.localOrientation.i1j2;
			manifold.localNormal.y = px * rectangle.localOrientation.i2j1 + py * rectangle.localOrientation.i2j2;
			
			manifold.normal.x = -(r11 * px + r12 * py);
			manifold.normal.y = -(r21 * px + r22 * py);
			
			manifold.localPoint.x = cx * rectangle.localOrientation.i1j1 + cy * rectangle.localOrientation.i1j2 + rectangle.localPosition.x;
			manifold.localPoint.y = cx * rectangle.localOrientation.i2j1 + cy * rectangle.localOrientation.i2j2 + rectangle.localPosition.y;

		}
		
		cp.id.generateKey();
		
		cp.position.x = circle.position.x + manifold.normal.x * circle.radius;
		cp.position.y = circle.position.y + manifold.normal.y * circle.radius;
		
		cp.r1.x = cp.position.x - circle.body.worldCenterOfMass.x;
		cp.r1.y = cp.position.y - circle.body.worldCenterOfMass.y;
		cp.r2.x = cp.position.x - rectangle.body.worldCenterOfMass.x;
		cp.r2.y = cp.position.y - rectangle.body.worldCenterOfMass.y;
		
		cp.localPoint.x = circle.body.orientation.i1j1 * cp.r1.x + circle.body.orientation.i2j1 * cp.r1.y + circle.body.localCenterOfMass.x;
		cp.localPoint.y = circle.body.orientation.i1j2 * cp.r1.x + circle.body.orientation.i2j2 * cp.r1.y + circle.body.localCenterOfMass.y;
		
		manifold.point1.separation = d - circle.radius;
	}

}