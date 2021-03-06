﻿/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.sat;
import draft.math.MathApprox;
import draft.physics.collisions.ICollisionHandler;
import draft.physics.collisions.shapes.CircleShape;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.dynamics.RigidBody;
import flash.Lib;

class SATCircleCircle
{

	public function new() 
	{
		
	}
	
	public function collide(circle1:CircleShape, circle2:CircleShape, contact:Contact):Void
	{
		
		var manifold:Manifold = contact.manifold;
		
		var p1x:Float = circle1.position.x;
		var p1y:Float = circle1.position.y;
		
		var p2x:Float = circle2.position.x;
		var p2y:Float = circle2.position.y;
		
		var dx:Float = p2x - p1x;
		var dy:Float = p2y - p1y;
		
		var distanceSquared:Float = dx * dx + dy * dy;
		var sumRadii = circle1.radius + circle2.radius;
		
		if (distanceSquared > sumRadii * sumRadii)
		{
			manifold.pointCount = 0;
			return;
		}
		
		var t:Float = MathApprox.invSqrt(distanceSquared);
		var distance:Float = 1 / t;
		var cp:ContactPoint = manifold.point1;
		
		cp.separation = distance - sumRadii;
		
		manifold.normal.x = t * dx;
		manifold.normal.y = t * dy;
		
		manifold.pointCount = 1;
		//trace(manifold.pointCount);
		cp.id.key = 0;
		
		p1x += circle1.radius * manifold.normal.x;
		p1y += circle1.radius * manifold.normal.y;
		p2x -= circle2.radius * manifold.normal.x;
		p2y -= circle2.radius * manifold.normal.y;
		
		cp.position.x = (p1x + p2x) * 0.5;
		cp.position.y = (p1y + p2y) * 0.5;

		var r1x:Float;
		var r1y:Float;
		
		var r2x:Float;
		var r2y:Float;
		
		var body1:RigidBody = circle1.body;
		var body2:RigidBody = circle2.body;
		
		r1x = cp.position.x - body1.worldCenterOfMass.x;
		r1y = cp.position.y - body1.worldCenterOfMass.y;
		
		cp.r1.x = r1x;
		cp.r1.y = r1y;
		
		r2x = cp.position.x - body2.worldCenterOfMass.x;
		r2y = cp.position.y - body2.worldCenterOfMass.y;
		
		cp.r2.x = r2x;
		cp.r2.y = r2y;
		
		manifold.manifoldType = Manifold.CIRCLE;
		manifold.localNormal.x = 0;
		manifold.localNormal.y = 0;
		manifold.localPoint = circle1.localPosition;
		manifold.point1.localPoint.x = circle2.localPosition.x;
		manifold.point1.localPoint.y = circle2.localPosition.y;
		manifold.point1.id.setKey(0);

	}
	
}