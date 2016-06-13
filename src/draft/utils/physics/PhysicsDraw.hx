/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils.physics;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.CircleShape;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.collisions.shapes.PolygonShape;
import draft.physics.collisions.shapes.RectangleShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactID;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.dynamics.RigidBody;
import draft.utils.graphics.DrawStyle;
import draft.utils.graphics.DrawUtils;
import flash.display.Graphics;

class PhysicsDraw 
{

	public function new() 
	{
		
	}
	
	public static inline function drawContact(canvas:Graphics, style:DrawStyle, contact:Contact, drawLocal:Bool)
	{
		var pos:Vector2D = new Vector2D();
		if (!drawLocal)
		{
			for (i in 0...contact.manifoldCount)
			{
				var m:Manifold = contact.manifoldArray[i];
				
				//*
				for (j in 0...m.pointCount)
				{
					var p:ContactPoint = m.pointArray[j];
					if (m.useSecondPoint)
						p = m.point2;
					pos.x = p.position.x - 2;
					pos.y = p.position.y - 2;
					DrawUtils.drawAABB(canvas, style, pos, 4, 4);
				}
				//*/
			}
		}
	}
	
	public static inline function drawRigidBody(canvas:Graphics, style:DrawStyle, body:RigidBody, drawLocal:Bool, drawOffset:Vector2D)
	{
		var offset:Vector2D = drawOffset.clone();
		if (drawLocal)
		{
			offset.x -= body.localCenterOfMass.x;
			offset.y -= body.localCenterOfMass.y;	
		}
		
		var walker:CollisionShape = body.shapeList;
		var n:Int = body.shapeCount;
		for (i in 0...n)
		{
			drawShape(canvas, style, walker, offset, drawLocal);
			walker = walker.next;
		}
		
		if (drawLocal)
			DrawUtils.drawPoint(canvas, style, drawOffset);
		else
		{
			
			var offset2:Vector2D = drawOffset.clone();
			offset2.x += body.worldCenterOfMass.x;
			offset2.y += body.worldCenterOfMass.y;
			DrawUtils.drawPoint(canvas, style, offset2);
		}
		
	}
	
	public static inline function drawShape(canvas:Graphics, style:DrawStyle, shape:CollisionShape, offset:Vector2D, drawLocal:Bool):Void
	{
		var p:Vector2D = new Vector2D();
		
		if (shape.shapeType == CollisionShape.CIRCLE_TYPE)
		{
			var c:CircleShape = cast(shape, CircleShape);
			
			if (drawLocal)
			{
				p.x = c.localPosition.x + offset.x;
				p.y = c.localPosition.y + offset.y;
			}else
			{
				p.x = c.position.x + offset.x;
				p.y = c.position.y + offset.y;
				
			}
			DrawUtils.drawCircle(canvas, style, p, c.radius);

		}else if (shape.shapeType == CollisionShape.RECTANGLE_TYPE)
		{
			var r:RectangleShape = cast(shape, RectangleShape);
			
			if (drawLocal)
			{
				p.x = r.localPosition.x + offset.x;
				p.y = r.localPosition.y + offset.y;
				
				
				DrawUtils.drawRectangle(canvas, style, p,
					new Vector2D(r.localOrientation.i1j1 * r.halfWidth, r.localOrientation.i2j1 * r.halfWidth),
					new Vector2D(r.localOrientation.i1j2 * r.halfHeight, r.localOrientation.i2j2 * r.halfHeight));
				
			}else
			{
				p.x = r.position.x + offset.x;
				p.y = r.position.y + offset.y;
				DrawUtils.drawRectangle(canvas, style, p, r.halfWidthVector, r.halfHeightVector);
			}
		}else if (shape.shapeType == CollisionShape.POLYGON_TYPE)
		{
			var poly:PolygonShape = cast(shape, PolygonShape);
			
			if (drawLocal)
			{
				p.x = poly.localPosition.x + offset.x;
				p.y = poly.localPosition.y + offset.y;
				
				DrawUtils.drawPolygon(canvas, style, poly.localVertexArray, p, poly.localOrientation);
			}else
			{
				DrawUtils.drawPolygon(canvas, style, poly.worldVertexArray, offset, new RotationMatrix2D());
			}			
		}
	}
	
}