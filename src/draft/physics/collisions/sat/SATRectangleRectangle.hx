/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.sat;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.ICollisionHandler;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.collisions.shapes.RectangleShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.dynamics.RigidBody;

class SATRectangleRectangle
{

	public function new() 
	{
		
	}
		/*
		 * 	  V2 |	E1	 | V1
		 *    ___|_______|____
		 *		 |		 |
		 * 	  E2 |		 | E0
		 * 	  ___|_______|____
		 *       |       |
		 * 	  V3 |	E3   | V0
		 */
	public function collide(rectangle1:RectangleShape, rectangle2:RectangleShape, contact:Contact):Void
	{
		var manifold:Manifold = contact.manifold;
		
		var minPenA:Float = Math.POSITIVE_INFINITY;
		var minPenB:Float = minPenA;
		var pen:Float;
		
		var dX:Float = rectangle2.position.x - rectangle1.position.x;
		var dY:Float = rectangle2.position.y - rectangle1.position.y;
		
		//rectangle and edges
		var edgeA:Int = 0;
		var edgeB:Int = 0;
		
		var radiusArray:Array<Float> = [rectangle1.halfWidth, rectangle1.halfHeight, rectangle2.halfWidth, rectangle2.halfHeight];
		var orientation:Array<Float> = [rectangle1.orientation.i1j1, rectangle1.orientation.i2j1, rectangle1.orientation.i1j2, rectangle1.orientation.i2j2, rectangle2.orientation.i1j1, rectangle2.orientation.i2j1, rectangle2.orientation.i1j2, rectangle2.orientation.i2j2];
		
		var normalAX:Float = 0;
		var normalAY:Float = 0;
		
		var localNormalAX:Float = 0;
		var localNormalAY:Float = 0;
		
		var planeOffsetA:Float = 0;
		
		var normalBX:Float = 0;
		var normalBY:Float = 0;
		
		var localNormalBX:Float = 0;
		var localNormalBY:Float = 0;
		
		var planeOffsetB:Float = 0;
		
		for (i in 0...2)
		{
			
			pen = testAxis(orientation[i * 2], orientation[i * 2 + 1], dX, dY, radiusArray[i], rectangle2.halfWidthVector,rectangle2.halfHeightVector);
			
			if (pen == 0)
			{
				manifold.pointCount = 0;
				contact.prevShape = 0;
				contact.prevAxis = i;
				return;
			}
			
			if (pen > 0)
			{
				if (pen < minPenA)
				{
					minPenA = pen;
					edgeA = i == 0 ? 0 : 3;
				}
			}else
			{
				if (-pen < minPenA)
				{
					minPenA = -pen;
					edgeA = i == 0 ? 2 : 1;
				}				
			}
		}
		
		for (i in 2...4)
		{
			
			pen = testAxis(orientation[i * 2], orientation[i * 2 + 1], dX, dY, radiusArray[i], rectangle1.halfWidthVector,rectangle1.halfHeightVector);
			
			if (pen == 0)
			{
				manifold.pointCount = 0;
				contact.prevShape = 0;
				contact.prevAxis = i;
				return;
			}
			
			if (pen > 0)
			{
				if (pen < minPenB)
				{
					minPenB = pen;
					edgeB = i == 2 ? 2 : 1;
				}
			}else
			{
				if (-pen < minPenB)
				{
					minPenB = -pen;
					edgeB = i == 2 ? 0 : 3;
				}				
			}
		}
		
		switch(edgeA)
		{
			case 0:
				localNormalAX = rectangle1.localOrientation.i1j1;
				localNormalAY = rectangle1.localOrientation.i2j1;
				normalAX = rectangle1.orientation.i1j1;
				normalAY = rectangle1.orientation.i2j1;
				planeOffsetA = rectangle1.halfWidth;
			case 1:
				localNormalAX = -rectangle1.localOrientation.i1j2;
				localNormalAY = -rectangle1.localOrientation.i2j2;
				normalAX = -rectangle1.orientation.i1j2;
				normalAY = -rectangle1.orientation.i2j2;
				planeOffsetA = rectangle1.halfHeight;
			case 2:
				localNormalAX = -rectangle1.localOrientation.i1j1;
				localNormalAY = -rectangle1.localOrientation.i2j1;
				normalAX = -rectangle1.orientation.i1j1;
				normalAY = -rectangle1.orientation.i2j1;
				planeOffsetA = rectangle1.halfWidth;
			case 3:
				localNormalAX = rectangle1.localOrientation.i1j2;
				localNormalAY = rectangle1.localOrientation.i2j2;
				normalAX = rectangle1.orientation.i1j2;
				normalAY = rectangle1.orientation.i2j2;
				planeOffsetA = rectangle1.halfHeight;
		}
		
		switch(edgeB)
		{
			case 0:
				localNormalBX = rectangle2.localOrientation.i1j1;
				localNormalBY = rectangle2.localOrientation.i2j1;
				normalBX = rectangle2.orientation.i1j1;
				normalBY = rectangle2.orientation.i2j1;
				planeOffsetB = rectangle2.halfWidth;
			case 1:
				localNormalBX = -rectangle2.localOrientation.i1j2;
				localNormalBY = -rectangle2.localOrientation.i2j2;
				normalBX = -rectangle2.orientation.i1j2;
				normalBY = -rectangle2.orientation.i2j2;
				planeOffsetB = rectangle2.halfHeight;
			case 2:
				localNormalBX = -rectangle2.localOrientation.i1j1;
				localNormalBY = -rectangle2.localOrientation.i2j1;
				normalBX = -rectangle2.orientation.i1j1;
				normalBY = -rectangle2.orientation.i2j1;
				planeOffsetB = rectangle2.halfWidth;
			case 3:
				localNormalBX = rectangle2.localOrientation.i1j2;
				localNormalBY = rectangle2.localOrientation.i2j2;
				normalBX = rectangle2.orientation.i1j2;
				normalBY = rectangle2.orientation.i2j2;
				planeOffsetB = rectangle2.halfHeight;
		}
		
		/*
		if (minPenA < minPenB)
		{
			manifold.point1.separation = -minPenA;
			manifold.normal.x = normalAX;
			manifold.normal.y = normalAY;
			manifold.point1.id.flip = 0;
			manifold.point1.id.referenceEdge = edgeA;
			manifold.point1.id.incidentEdge = edgeB;
		}else
		{
			manifold.point1.separation = -minPenB;
			manifold.normal.x = normalBX;
			manifold.normal.y = normalBY;
			manifold.point1.id.flip = 1;
			manifold.point1.id.referenceEdge = edgeB;
			manifold.point1.id.incidentEdge = edgeA;
			
		}//*/
		
		
		//////////////////////////////////////////////////////////////////
		//*
		var flip:Int;
		var referenceEdge:Int;
		var incidentEdge:Int;
		var vertices1:Array<Vector2D>;
		var vertices2:Array<Vector2D>;
		var shapeA:RectangleShape;
		var shapeB:RectangleShape;
		
		var relativeTolerance:Float = 0.98;
		var absoluteTolerance:Float = 0.001;
		if (minPenA > relativeTolerance * minPenB + absoluteTolerance)
		{
			flip = 1;
			contact.prevShape = 1;
			contact.prevAxis = edgeB & 1;
			
			referenceEdge = edgeB;
			incidentEdge = edgeA;
			var tx:Float = normalAX;
			var ty:Float = normalAY;
			normalAX = normalBX;
			normalAY = normalBY;
			normalBX = tx;
			normalBY = ty;
			vertices1 = rectangle2.worldVertexArray;
			vertices2 = rectangle1.worldVertexArray;
			shapeA = rectangle2;
			shapeB = rectangle1;
			localNormalAX = localNormalBX;
			localNormalAY = localNormalBY;
			planeOffsetA = planeOffsetB;
			manifold.manifoldType = Manifold.FACE_B;
		}
		else 
		{
			flip = 0;
			contact.prevShape = 0;
			//edgeA % 2
			contact.prevAxis = edgeA & 1;
			referenceEdge = edgeA;
			incidentEdge = edgeB;
			vertices1 = rectangle1.worldVertexArray;
			vertices2 = rectangle2.worldVertexArray;
			shapeA = rectangle1;
			shapeB = rectangle2;
			manifold.manifoldType = Manifold.FACE_A;
		}
		
		manifold.localNormal.x = localNormalAX;
		manifold.localNormal.y = localNormalAY;
		manifold.localPoint.x = localNormalAX * planeOffsetA + shapeA.localPosition.x;
		manifold.localPoint.y = localNormalAY * planeOffsetA + shapeA.localPosition.y;
		minPenA = normalBX * normalAX + normalBY * normalAY;
		
		minPenB = -normalBY * normalAX + normalBX * normalAY;
		if (minPenB < 0)
		{
			if(minPenB < minPenA){
				incidentEdge = incidentEdge == 0 ? 3 : (incidentEdge - 1);
			}
			
		}else if(-minPenB < minPenA){
			incidentEdge = incidentEdge == 3 ? 0 : (incidentEdge + 1);
		}
		
		
		
		//*
		var v2:Vector2D = vertices1[referenceEdge];
		var v1:Vector2D = v2.next;
		
		//*
		var snx:Float = -normalAY;
		var sny:Float = normalAX;
		
		var sideOffset1:Float = -(snx * v1.x + sny * v1.y);
		var sideOffset2:Float = snx * v2.x + sny * v2.y;
		
		var incidentIndex1:Int = incidentEdge == 3 ? 0 : (incidentEdge + 1);
		var incidentIndex2:Int = incidentEdge;
		var i2:Vector2D = vertices2[incidentIndex2];
		var i1:Vector2D = i2.next;
		
		//*
		var distance0:Float = -snx * i1.x - sny * i1.y - sideOffset1;
		var distance1:Float = -snx * i2.x - sny * i2.y - sideOffset1;
		
		var c11x:Float = 0;
		var c11y:Float = 0;
		var c12x:Float = 0;
		var c12y:Float = 0;
		
		var n:Int = 0;
		
		var outV1:Int = 0;
		var outV2:Int = 0;
		var outI1:Int = 0;
		var outI2:Int = 0;
		
		if(distance0 <= 0)
		{
			c11x = i1.x;
			c11y = i1.y;
			outV1 = 0;
			outI1 = incidentIndex1;
			n++;
		}
		if(distance1 <= 0)
		{
			if(n == 0){
				c11x = i2.x;
				c11y = i2.y;
				outV1 = 1;
				outI1 = incidentIndex2;
			}
			else{
				c12x = i2.x;
				c12y = i2.y;
				outV2 = 1;
				outI2 = incidentIndex2;
			}
			n++;
		}
		var intersection:Float;
		if(distance0 * distance1 < 0)
		{
			intersection = distance0 / (distance0 - distance1);
			if(n == 0)
			{
				c11x = i1.x + intersection * (i2.x - i1.x);
				c11y = i1.y + intersection * (i2.y - i1.y);
			}
			else
			{
				c12x = i1.x + intersection * (i2.x - i1.x);
				c12y = i1.y + intersection * (i2.y - i1.y);
			}
			if(distance0 > 0){
				if(n == 0){
					outV1 = 0;
					outI1 = incidentIndex1;
				}
				else
				{
					outV2 = 0;
					outI2 = incidentIndex1;
				}
			}else{
				if(n == 0)
				{
					outV1 = 1;
					outI1 = incidentIndex2;
				}else{
					outV2 = 1;
					outI2 = incidentIndex2;
				}
			}
			n++;
		}
		
		if(n < 2){
			manifold.pointCount = 0;
			return;
		}
			
		distance0 = snx * c11x + sny * c11y - sideOffset2;
		distance1 = snx * c12x + sny * c12y - sideOffset2;
		
		var c21x:Float = 0;
		var c21y:Float = 0;
		var c22x:Float = 0;
		var c22y:Float = 0;
		
		var iV1:Int = 0;
		var iV2:Int = 0;
		
		n = 0;
		
		if(distance0 <= 0)
		{
			c21x = c11x;
			c21y = c11y;
			iV1 = outV1;
			incidentIndex1 = outI1;
			n++;
		}
		
		if(distance1 <= 0)
		{
			if(n == 0){
				c21x = c12x;
				c21y = c12y;
				iV1 = outV2;
				incidentIndex1 = outI2;
			}else{
				c22x = c12x;
				c22y = c12y;
				iV2 = outV2;
				incidentIndex2 = outI2;
			}
			n++;
		}
		
		if(distance0 * distance1 < 0)
		{
			intersection = distance0 / (distance0 - distance1);
			if(n == 0)
			{
				c21x = c11x + intersection * (c12x - c11x);
				c21y = c11y + intersection * (c12y - c11y);
			}
			else
			{
				c22x = c11x + intersection * (c12x - c11x);
				c22y = c11y + intersection * (c12y - c11y);
			}
			if(distance0 > 0){
				if(n == 0){
					iV1 = outV1;
					incidentIndex1 = outI1;
				}
				else
				{
					iV2 = outV1;
					incidentIndex2 = outI1;
				}
			}else{
				if(n == 0)
				{
					iV1 = outV2;
					incidentIndex1 = outI2;
				}else{
					iV2 = outV2;
					incidentIndex2 = outI2;
				}
			}
			n++;
		}
		
		if(n < 2){
			manifold.pointCount = 0;
			return;
		}
		
		//*
		
		if(flip == 0){
			manifold.normal.x = normalAX;
			manifold.normal.y = normalAY;
		}else{
			manifold.normal.x = -normalAX;
			manifold.normal.y = -normalAY;
		}
		
		var pointCount:Int = 0;
		var frontOffset:Float = normalAX * v1.x + normalAY * v1.y;
		var cp:ContactPoint;
		
		var r1x:Float;
		var r1y:Float;
		
		var r2x:Float;
		var r2y:Float;
		
		var body1:RigidBody = rectangle1.body;
		var body2:RigidBody = rectangle2.body;
		
		var orientation:RotationMatrix2D;
		var separation:Float = normalAX * c21x + normalAY * c21y - frontOffset;
		
		if(separation <= 0){
			cp = manifold.point1;
			cp.separation = separation;
			cp.position.x = c21x;
			cp.position.y = c21y;
			cp.id.flip = flip;
			cp.id.referenceEdge = referenceEdge;
			cp.id.incidentEdge = incidentIndex1;
			cp.id.incidentVertex = iV1;
			cp.id.generateKey();
						
			r1x = c21x - body1.worldCenterOfMass.x;
			r1y = c21y - body1.worldCenterOfMass.y;
					
			cp.r1.x = r1x;
			cp.r1.y = r1y;
					
			r2x = c21x - body2.worldCenterOfMass.x;
			r2y = c21y - body2.worldCenterOfMass.y;
					
			cp.r2.x = r2x;
			cp.r2.y = r2y;
					
			if(manifold.manifoldType == Manifold.FACE_B){
				orientation = body1.orientation;
				cp.localPoint.x = orientation.i1j1 * r1x + orientation.i2j1 * r1y + body1.localCenterOfMass.x;
				cp.localPoint.y = orientation.i1j2 * r1x + orientation.i2j2 * r1y + body1.localCenterOfMass.y;
			}else{
				orientation = body2.orientation;
				cp.localPoint.x = orientation.i1j1 * r2x + orientation.i2j1 * r2y + body2.localCenterOfMass.x;
				cp.localPoint.y = orientation.i1j2 * r2x + orientation.i2j2 * r2y + body2.localCenterOfMass.y;
			}
			if(separation <= 0)
				pointCount++;
		}
		
		separation = normalAX * c22x + normalAY * c22y - frontOffset;
		if(separation <= 0){
			cp = manifold.pointArray[pointCount];
			cp.separation = separation;
			cp.position.x = c22x;
			cp.position.y = c22y;
			cp.id.flip = flip;
			cp.id.referenceEdge = referenceEdge;
			cp.id.incidentEdge = incidentIndex2;
			cp.id.incidentVertex = iV2;
			cp.id.generateKey();
			
			r1x = c22x - body1.worldCenterOfMass.x;
			r1y = c22y - body1.worldCenterOfMass.y;
					
			cp.r1.x = r1x;
			cp.r1.y = r1y;
					
			r2x = c22x - body2.worldCenterOfMass.x;
			r2y = c22y - body2.worldCenterOfMass.y;
					
			cp.r2.x = r2x;
			cp.r2.y = r2y;
					
			if(manifold.manifoldType == Manifold.FACE_B){
				orientation = body1.orientation;
				cp.localPoint.x = orientation.i1j1 * r1x + orientation.i2j1 * r1y + body1.localCenterOfMass.x;
				cp.localPoint.y = orientation.i1j2 * r1x + orientation.i2j2 * r1y + body1.localCenterOfMass.y;
			}else{
				orientation = body2.orientation;
				cp.localPoint.x = orientation.i1j1 * r2x + orientation.i2j1 * r2y + body2.localCenterOfMass.x;
				cp.localPoint.y = orientation.i1j2 * r2x + orientation.i2j2 * r2y + body2.localCenterOfMass.y;
			}
			if (separation <= 0)
				pointCount++;
		}
		
		manifold.pointCount = pointCount;//*/
	}
	
	private inline function testAxis(axisX:Float, axisY:Float, dX:Float, dY:Float, rect1R:Float, rect2HW:Vector2D, rect2HH:Vector2D):Float
	{
		var proj1:Float = axisX * rect2HH.x + axisY * rect2HH.y;
		var proj2:Float = axisX * rect2HW.x + axisY * rect2HW.y;
		
		proj1 = (proj1 > 0 ? proj1 : -proj1) + (proj2 > 0 ? proj2 : -proj2);
		proj2 = dX * axisX + dY * axisY;
		
		var proj2ABS:Float = proj2 > 0 ? proj2 : -proj2;
		var r:Float;
		
		if ((proj1 + rect1R) < proj2ABS){
			r = 0;
		}else if (proj2 > 0)
		{
			r = proj1 + rect1R - proj2ABS;
		}else
		{
			r = proj2ABS - proj1 - rect1R;
		}
		
		return r;
	}
	
}