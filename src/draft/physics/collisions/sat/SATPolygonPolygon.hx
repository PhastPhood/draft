/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.sat;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.collisions.shapes.PolygonShape;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.dynamics.RigidBody;

class SATPolygonPolygon 
{

	public function new() 
	{
		
	}
	
	public function collide(polygon1:PolygonShape, polygon2:PolygonShape, contact:Contact):Void
	{
		var manifold:Manifold = contact.manifold;
		
		var curPen:Float;
		var minPenA:Float = Math.POSITIVE_INFINITY;
		var minPenB:Float = Math.POSITIVE_INFINITY;
		
		var dX:Float = polygon2.worldCenter.x - polygon1.worldCenter.x;
		var dY:Float = polygon2.worldCenter.y - polygon1.worldCenter.y;
		
		var normal:Vector2D;
		var vertex:Vector2D;
		
		var pMax:Float;
		var pMin:Float;
		var curProj:Float;
		
		var edgeA:Int = 0;
		
		var localNormalAX:Float = 0;
		var localNormalAY:Float = 0;
		
		var normalAX:Float = 0;
		var normalAY:Float = 0;
		
		var edgeB:Int = 0;
		
		var localNormalBX:Float = 0;
		var localNormalBY:Float = 0;
		
		var normalBX:Float = 0;
		var normalBY:Float = 0;
		
		for (i in 0...polygon1.vertexCount)
		{
			normal = polygon1.worldNormalArray[i];
			if (normal.x * dX + normal.y * dY >= 0)
			{
				vertex = polygon1.worldVertexArray[i];
				pMax = normal.x * vertex.x + normal.y * vertex.y;
				
				pMin = Math.POSITIVE_INFINITY;
				for ( j in 0...polygon2.vertexCount)
				{
					vertex = polygon2.worldVertexArray[j];
					curProj = vertex.x * normal.x + vertex.y * normal.y;
					
					if (curProj < pMin)
					{
						pMin = curProj;
					}
				}
				
				if (pMin > pMax)
				{
					manifold.pointCount = 0;
					contact.prevShape = 0;
					contact.prevAxis = i % polygon1.vertexCount;
					return;
				}
				
				curPen = pMax - pMin;
				
				if (curPen < minPenA)
				{
					minPenA = curPen;
					normalAX = normal.x;
					normalAY = normal.y;
					edgeA = i % polygon1.vertexCount;
					localNormalAX = polygon1.localNormalArray[edgeA].x;
					localNormalAY = polygon1.localNormalArray[edgeA].y;
				}
			}
		}
		
		for (i in 0...polygon2.vertexCount)
		{
			normal = polygon2.worldNormalArray[i].clone();
			if (normal.x * -dX + normal.y * -dY >= 0)
			{
				vertex = polygon2.worldVertexArray[i];
				pMax = normal.x * vertex.x + normal.y * vertex.y;
				
				pMin = Math.POSITIVE_INFINITY;
				for ( j in 0...polygon1.vertexCount)	
				{
					vertex = polygon1.worldVertexArray[j];
					curProj = vertex.x * normal.x + vertex.y * normal.y;
					
					if (curProj < pMin)
					{
						pMin = curProj;
					}
				}
				
				if (pMin > pMax)
				{
					manifold.pointCount = 0;
					contact.prevShape = 0;
					contact.prevAxis = i % polygon2.vertexCount;
					return;
				}
				
				curPen = pMax - pMin;
				if (curPen < minPenB)
				{
					minPenB = curPen;
					normalBX = normal.x;
					normalBY = normal.y;
					edgeB = i % polygon2.vertexCount;
					localNormalBX = polygon2.localNormalArray[edgeB].x;
					localNormalBY = polygon2.localNormalArray[edgeB].y;
				}
			}
		}
		
		var flip:Int;
		var referenceEdge:Int;
		var incidentEdge:Int;
		var vertices1:Array<Vector2D>;
		var vertices2:Array<Vector2D>;
		var shapeA:PolygonShape;
		var shapeB:PolygonShape;
		
		var relativeTolerance:Float = 0.98;
		var absoluteTolerance:Float = 0.001;
		
		var v1:Vector2D = new Vector2D();
		var v2:Vector2D = new Vector2D();
		var maxIVertices:Int;
		var maxRVertices:Int;
		
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
			vertices1 = polygon2.worldVertexArray;
			vertices2 = polygon1.worldVertexArray;
			shapeA = polygon2;
			shapeB = polygon1;
			localNormalAX = localNormalBX;
			localNormalAY = localNormalBY;
			manifold.manifoldType = Manifold.FACE_B;
						
			maxIVertices = polygon1.vertexCount;
			maxRVertices = polygon2.vertexCount;
		}
		else 
		{
			flip = 0;
			contact.prevShape = 0;
			//edgeA % 2
			contact.prevAxis = edgeA & 1;
			referenceEdge = edgeA;
			incidentEdge = edgeB;
			vertices1 = polygon1.worldVertexArray;
			vertices2 = polygon2.worldVertexArray;
			shapeA = polygon1;
			shapeB = polygon2;
			manifold.manifoldType = Manifold.FACE_A;
			
			maxRVertices = polygon1.vertexCount;
			maxIVertices = polygon2.vertexCount;
		}
		var orientation:RotationMatrix2D = shapeA.localOrientation;
		var vA:Vector2D = shapeA.localVertexArray[referenceEdge];
		var vB:Vector2D = vA.next;
		v1 = new Vector2D();
		v2 = new Vector2D();
		v1.x = vA.x * orientation.i1j1 + vA.y * orientation.i1j2 + shapeA.localPosition.x;
		v1.y = vA.x * orientation.i2j1 + vA.y * orientation.i2j2 + shapeA.localPosition.y;
		v2.x = vB.x * orientation.i1j1 + vB.y * orientation.i1j2 + shapeA.localPosition.x;
		v2.y = vB.x * orientation.i2j1 + vB.y * orientation.i2j2 + shapeA.localPosition.y;
		
		manifold.localPoint.x = (v1.x + v2.x) * 0.5;
		manifold.localPoint.y = (v1.y + v2.y) * 0.5;
		
		manifold.localNormal.x = localNormalAX * orientation.i1j1 + localNormalAY * orientation.i1j2;
		manifold.localNormal.y = localNormalAX * orientation.i2j1 + localNormalAY * orientation.i2j2;
		
			
		minPenA = normalBX * normalAX + normalBY * normalAY;
		
		for (i in 0...shapeB.vertexCount) {
			v1 = shapeB.worldNormalArray[i];
			minPenB = v1.x * normalAX + v1.y * normalAY;
			
			if (minPenB < minPenA) {
				minPenA = minPenB;
				incidentEdge = i;
			}
		}
		
		v2 = vertices1[referenceEdge];
		v1 = v2.next;
		//*
		var snx:Float = -normalAY;
		var sny:Float = normalAX;
		
		var sideOffset1:Float = -(snx * v1.x + sny * v1.y);
		var sideOffset2:Float = snx * v2.x + sny * v2.y;
		
		var incidentIndex1:Int = (incidentEdge == (maxIVertices - 1)) ? 0 : (incidentEdge + 1);
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
		var separation:Float = normalAX * c21x + normalAY * c21y - frontOffset;
		var cp:ContactPoint;
		
		var r1x:Float;
		var r1y:Float;
		
		var r2x:Float;
		var r2y:Float;
		
		var body1:RigidBody = polygon1.body;
		var body2:RigidBody = polygon2.body;
		
		var orientation:RotationMatrix2D;
		
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
			pointCount++;
		}
		
		manifold.pointCount = pointCount;//*/
	}
	
}