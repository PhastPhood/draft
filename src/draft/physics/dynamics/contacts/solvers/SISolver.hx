/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics.contacts.solvers;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.dynamics.RigidBody;

class SISolver extends ContactSolver
{

	public var manifoldArray:Array<Manifold>;
	public var manifoldCount:Int;
	
	public var velocityThreshhold:Float;
	public var doWarmStarting:Bool;
	
	public var positionCorrectionIterations:Int;
	public var linearSlop:Float;
	public var maxLinearCorrection:Float;
	public var biasFactor:Float;
	
	public var contactBaumgarte:Float;
	
	public var inversedt:Float;
	
	public function new() 
	{
		super();
		manifoldArray = new Array<Manifold>();
		
		velocityThreshhold = 40;
		linearSlop = 0.7;
		maxLinearCorrection = 8;
		positionCorrectionIterations = 5;
		contactBaumgarte = 0.7;
		biasFactor = 0.05;
		
		doWarmStarting = true;
	}
	
	public override function solve(dt:Float, iterations:Int):Void
	{
		inversedt = 1 / dt;
		
		var body:RigidBody;
		for (i in 0...bodyCount)
		{
			body = bodyArray[i];
			body.minSeparation = 0;
			if (body.isStatic)
				continue;
				
			body.accumulateForces();
			
			body.velocity.x += body.accumulatedForce.x * body.invMass * dt;
			body.velocity.y += body.accumulatedForce.y * body.invMass * dt;
			body.angularVelocity += body.accumulatedTorque * body.invI * dt;
			body.clearForces();
		}
		
		initVelocityConstraints();
		
		for (i in 0...iterations)
		{
			solveVelocityConstraints();
		}
		
		for (i in 0...bodyCount)
		{
			body = bodyArray[i];
			if (body.isStatic)
				continue;
			body.position.x += body.velocity.x * dt;
			body.position.y += body.velocity.y * dt;
			body.setRotation(body.getRotation() + body.angularVelocity * dt);
			body.synchronizeTransform();
		}
		
		var contactsOkay:Bool;
		//*
		for (i in 0...positionCorrectionIterations)
		{
			contactsOkay = solvePositionConstraints();
			if (contactsOkay)
				break;
		}//*/
		
	}
	
	public function initVelocityConstraints():Void
	{
		manifoldCount = 0;
		var mLen:Int = manifoldArray.length;
		var contact:Contact;
		
		var body1:RigidBody;
		var body2:RigidBody;
		
		var massSum:Float;
		
		var v1x:Float;
		var v1y:Float;
		var v2x:Float;
		var v2y:Float;
		
		var w1:Float;
		var w2:Float;
		
		var manifold:Manifold;
		var m:Array<Manifold>;
		var mCount:Int;

		var normalx:Float;
		var normaly:Float;
		var tangentx:Float;
		var tangenty:Float;
		
		var pCount:Int;
		
		var cp:ContactPoint;
		var kNormal:Float;
		var kEqualized:Float;
		var kTangent:Float;
		
		var rn1:Float;
		var rn2:Float;
		
		var rt1:Float;
		var rt2:Float;
		
		var r1x:Float = 0;
		var r1y:Float = 0;
		var r2x:Float = 0;
		var r2y:Float = 0;
		
		var t1:Float;
		var t2:Float;
		
		var dvx:Float;
		var dvy:Float;
		var vRel:Float;
		
		var px:Float;
		var py:Float;
		
		var cp1:ContactPoint;
		var cp2:ContactPoint;
		
		var determinant:Float;
		
		var rn11:Float;
		var rn12:Float;
		var rn21:Float;
		var rn22:Float;
		
		var k11:Float;
		var k12:Float;
		var k22:Float;
		
		var useNormalMass:Bool;
		var i:Int;
		var j:Int;
		var k:Int;
		
		var prevUSP:Bool;
		
		for (i in 0...contactCount)
		{
			contact = contactArray[i];
			/*if (contact.shape1.resolutionGroup == contact.shape2.resolutionGroup && contact.shape1.resolutionGroup != 0)
			{
				if (contact.shape1.collisionGroup < 0)
					continue;
			}else
			{
				if ((contact.shape1.resolutionMask & contact.shape2.resolutionCategory == 0) || (contact.shape2.resolutionMask & contact.shape1.resolutionCategory == 0))
					continue;
			}*/
			body1 = contact.shape1.body;
			body2 = contact.shape2.body;
			massSum = body1.invMass + body2.invMass;
			v1x = body1.velocity.x;
			v1y = body1.velocity.y;
			v2x = body2.velocity.x;
			v2y = body2.velocity.y;
			w1 = body1.angularVelocity;
			w2 = body2.angularVelocity;
			m = contact.manifoldArray;
			mCount = contact.manifoldCount;
			
			for (j in 0...mCount)
			{
				manifold = m[j];
				
				prevUSP = manifold.useSecondPoint;
				manifold.useSecondPoint = false;
				normalx = manifold.normal.x;
				normaly = manifold.normal.y;				
				
				tangentx = normaly;
				tangenty = -normalx;
				
				if (manifoldCount < mLen)
				{
					manifoldArray[manifoldCount] = manifold;
				}else
				{
					manifoldArray.push(manifold);
					mLen++;
				}
				
				manifoldCount++;
				pCount = manifold.pointCount;
				useNormalMass = (body1.invMass == 0) && (body2.invMass == 0);
				if (useNormalMass)
				{
					manifold.invMass1 = 0;
					manifold.invMass2 = 0;
					
					manifold.invI1 = body1.invI;
					manifold.invI2 = body2.invI;
				}else
				{
					manifold.invMass1 = body1.invMass * body1.mass;
					manifold.invMass2 = body2.invMass * body2.mass;
					manifold.invI1 = body1.invI * body1.mass;
					manifold.invI2 = body2.invI * body2.mass;
				}
				
				
				for (k in 0...pCount)
				{
					cp = manifold.pointArray[k];
					r1x = cp.r1.x;
					r1y = cp.r1.y;
					
					r2x = cp.r2.x;
					r2y = cp.r2.y;
					
					rn1 = r1x * normalx + r1y * normaly;
					rn2 = r2x * normalx + r2y * normaly;
					
					rt1 = r1x * tangentx + r1y * tangenty;
					rt2 = r2x * tangentx + r2y * tangenty;
					
					t1 = rt1 * rt1;
					t2 = rt2 * rt2;
					
					kNormal = massSum + body1.invI * t1 + body2.invI * t2;
					cp.normalMass = 1 / kNormal;
						
					kEqualized = body1.mass * body1.invMass + body2.mass * body2.invMass;
					kEqualized += body1.mass * body1.invI * t1 + body2.mass * body2.invI * t2;
					cp.equalizedMass = useNormalMass ? cp.normalMass : 1 / kEqualized;
					
					/*kEqualized = manifold.invMass1 + manifold.invMass2;
					kEqualized += manifold.invI1 * t1 + manifold.invI2 * t2;
					cp.equalizedMass = useNormalMass ? cp.normalMass : 1 / kEqualized;*/
					
					kTangent = massSum + body1.invI * (rn1 * rn1) + body2.invI * (rn2 * rn2);
					cp.tangentMass = 1 / kTangent;
					
					cp.velocityBias = 0;
					if (cp.separation > 0)
					{
						cp.velocityBias = -60 * cp.separation;
					}
					else
					{
						dvx = v2x - w2 * r2y - (v1x - w1 * r1y);
						dvy = v2y + w2 * r2x - (v1y + w1 * r1x);
						vRel = normalx * dvx + normaly * dvy;
						if (vRel < -velocityThreshhold)
							cp.velocityBias = -cp.restitution * vRel;
					}
					/*
					//if(positionCorrectionStrategy == PositionCorrectionStrategies.BAUMGARTE_STABILIZATION)
					//{
						t1 = cp.separation + linearSlop;
						cp.velocityBias -= biasFactor * inversedt * (t1 < 0 ? t1 : 0);
					//}//*/
					

				}
				if (pCount == 2)
				{
					cp1 = manifold.point1;
					cp2 = manifold.point2;
					//a.x * b.y - a.y * b.x	
					/*float32 rn1A = b2Cross(ccp1->rA, cc->normal);
					float32 rn1B = b2Cross(ccp1->rB, cc->normal);
					float32 rn2A = b2Cross(ccp2->rA, cc->normal);
					float32 rn2B = b2Cross(ccp2->rB, cc->normal);*/
					rn11 = cp1.r1.x * normaly - cp1.r1.y * normalx;
					rn12 = cp1.r2.x * normaly - cp1.r2.y * normalx;
					rn21 = cp2.r1.x * normaly - cp2.r1.y * normalx;
					rn22 = cp2.r2.x * normaly - cp2.r2.y * normalx;
					
					k11 = massSum + body1.invI * rn11 * rn11 + body2.invI * rn12 * rn12;
					k12 = massSum + body1.invI * rn11 * rn21 + body2.invI * rn12 * rn22;
					k22 = massSum + body1.invI * rn21 * rn21 + body2.invI * rn22 * rn22;
					
					var maxConditionNumber:Float = 100000;
					determinant = k11 * k22 - k12 * k12;
					if(k11 * k11 < maxConditionNumber * (k11 * k22 - k12 * k12))
					{
						manifold.kN11 = k11;
						manifold.kN12 = k12;
						manifold.kN21 = k12;
						manifold.kN22 = k22;
						
						determinant = 1 / determinant;
						manifold.normalMass11 = k22 * determinant;
						manifold.normalMass12 = k12 * -determinant;
						manifold.normalMass21 = manifold.normalMass12;
						manifold.normalMass22 = k11 * determinant;
						//trace("k11: " + k11 + ", k12: " + k12 + ", k22: " + k22);
						
						if (useNormalMass) {
							manifold.kE11 = k11;
							manifold.kE12 = k12;
							manifold.kE21 = k12;
							manifold.kE22 = k22;
							
							manifold.equalizedMass11 = manifold.normalMass11;
							manifold.equalizedMass12 = manifold.normalMass12;
							manifold.equalizedMass21 = manifold.normalMass21;
							manifold.equalizedMass22 = manifold.normalMass22;
						}else {
							massSum = manifold.invMass1 + manifold.invMass2;
							k11 = massSum + manifold.invI1 * rn11 * rn11 + manifold.invI2 * rn12 * rn12;
							k12 = massSum + manifold.invI1 * rn11 * rn21 + manifold.invI2 * rn12 * rn22;
							//k21 = massSum + invI1 * rn21 * rn12 + invI2 * rn22 * rn22;
							k22 = massSum + manifold.invI1 * rn21 * rn21 + manifold.invI2 * rn22 * rn22;
							
							manifold.kE11 = k11;
							manifold.kE12 = k12;
							manifold.kE21 = k12;
							manifold.kE22 = k22;
							
							determinant = k11 * k22 - k12 * k12;
							determinant = 1 / determinant;
							manifold.equalizedMass11 = k22 * determinant;
							manifold.equalizedMass12 = k12 * -determinant;
							manifold.equalizedMass21 = manifold.equalizedMass12;
							manifold.equalizedMass22 = k11 * determinant;
						}
					}
					else
					{
						manifold.pointCount = 1;
						pCount = 1;
						if(manifold.point1.separation > manifold.point2.separation)
							manifold.useSecondPoint = true;
					}

				}
				
				if (doWarmStarting)
				{
					if (pCount == 1 || prevUSP == true)
					{
						
						cp = manifold.useSecondPoint ? manifold.point2 : manifold.point1;
						
						px = cp.normalImpulse * normalx + cp.tangentImpulse * tangentx;
						py = cp.normalImpulse * normaly + cp.tangentImpulse * tangenty;
						
						v1x -= body1.invMass * px;
						v1y -= body1.invMass * py;
						w1 -= body1.invI * (r1x * py - r1y * px);
						
						v2x += body2.invMass * px;
						v2y += body2.invMass * py;
						w2 += body2.invI * (r2x * py - r2y * px);
						
						body1.velocity.x = v1x;
						body1.velocity.y = v1y;
						body1.angularVelocity = w1;
						
						body2.velocity.x = v2x;
						body2.velocity.y = v2y;
						body2.angularVelocity = w2;
					}else
					{
						for (k in 0...pCount) 
						{
							cp = manifold.pointArray[k];
							r1x = cp.r1.x;
							r1y = cp.r1.y;
							
							r2x = cp.r2.x;
							r2y = cp.r2.y;
							
							px = cp.normalImpulse * normalx + cp.tangentImpulse * tangentx;
							py = cp.normalImpulse * normaly + cp.tangentImpulse * tangenty;
							
							v1x -= body1.invMass * px;
							v1y -= body1.invMass * py;
							w1 -= body1.invI * (r1x * py - r1y * px);
							
							v2x += body2.invMass * px;
							v2y += body2.invMass * py;
							w2 += body2.invI * (r2x * py - r2y * px);
							
							body1.velocity.x = v1x;
							body1.velocity.y = v1y;
							body1.angularVelocity = w1;
							
							body2.velocity.x = v2x;
							body2.velocity.y = v2y;
							body2.angularVelocity = w2;
						}
					}
				}else
				{
					for (k in 0...pCount) 
					{
						
						manifold.pointArray[k].normalImpulse = 0;
						manifold.pointArray[k].tangentImpulse = 0;
						
						
					}
					
				}
			}
			
		}
	}
	
	public function solveVelocityConstraints():Void
	{
		var manifold:Manifold;
		var cp1:ContactPoint;
		var cp2:ContactPoint;
		var body1:RigidBody;
		var body2:RigidBody;
		
		var w1:Float;
		var w2:Float;
		var v1x:Float;
		var v1y:Float;
		var v2x:Float;
		var v2y:Float;
		
		var normalx:Float;
		var normaly:Float;
		
		var tangentx:Float;
		var tangenty:Float;
		
		var dv1x:Float;
		var dv1y:Float;
		
		var dv2x:Float;
		var dv2y:Float;
		
		var p1x:Float;
		var p1y:Float;
		
		var p2x:Float;
		var p2y:Float;
		
		var vn1:Float;
		var vn2:Float;
		var vt:Float;
		var lambda:Float;
		var t:Float;
		var newImpulse:Float;
		
		var r1x:Float;
		var r1y:Float;
		var r2x:Float;
		var r2y:Float;
		
		var maxFriction:Float;
		
		var min:Float;
		var pCoint:Int;
		
		var a1:Float;
		var a2:Float;
		
		var b1:Float;
		var b2:Float;
		
		var x1:Float;
		var x2:Float;
		
		var d1:Float;
		var d2:Float;
		
		var noSolution:Bool;
		
		var i:Int;
		var j:Int;
		var pCount:Int;
		for (i in 0...manifoldCount)
		{
			manifold = manifoldArray[i];
			pCount = manifold.pointCount;
			body1 = manifold.body1;
			body2 = manifold.body2;
			w1 = body1.angularVelocity;
			w2 = body2.angularVelocity;
			v1x = body1.velocity.x;
			v1y = body1.velocity.y;
			v2x = body2.velocity.x;
			v2y = body2.velocity.y;
			normalx = manifold.normal.x;
			normaly = manifold.normal.y;
			tangentx = normaly;
			tangenty = -normalx;
			
			
			pCoint = manifold.pointCount;
			
			if (pCoint == 1)
			{
				cp1 = manifold.useSecondPoint ? manifold.point2 : manifold.point1;
				r1x = cp1.r1.x;
				r1y = cp1.r1.y;
				r2x = cp1.r2.x;
				r2y = cp1.r2.y;
				//relative velocity at contact
				dv1x = v2x - w2 * r2y - (v1x - w1 * r1y);
				dv1y = v2y + w2 * r2x - (v1y + w1 * r1x);
				
				vn1 = dv1x * normalx + dv1y * normaly;
				lambda = -cp1.normalMass * (vn1 - cp1.velocityBias);
				
				t = cp1.normalImpulse + lambda;
				newImpulse = t > 0 ? t : 0;
				lambda = newImpulse - cp1.normalImpulse;
				
				p1x = lambda * normalx;
				p1y = lambda * normaly;
				
				cp1.normalImpulse = newImpulse;
				
				v1x -= body1.invMass * p1x;
				v1y -= body1.invMass * p1y;
				w1 -= body1.invI * (r1x * p1y - r1y * p1x);
				
				v2x += body2.invMass * p1x;
				v2y += body2.invMass * p1y;
				w2 += body2.invI * (r2x * p1y - r2y * p1x);
				
			}else
			{
				noSolution = false;
				cp1 = manifold.point1;
				cp2 = manifold.point2;
				a1 = cp1.normalImpulse;
				a2 = cp2.normalImpulse;
				
				dv1x = v2x - w2 * cp1.r2.y - (v1x - w1 * cp1.r1.y);
				dv1y = v2y + w2 * cp1.r2.x - (v1y + w1 * cp1.r1.x);
				
				dv2x = v2x - w2 * cp2.r2.y - (v1x - w1 * cp2.r1.y);
				dv2y = v2y + w2 * cp2.r2.x - (v1y + w1 * cp2.r1.x);
				
				vn1 = dv1x * normalx + dv1y * normaly;
				vn2 = dv2x * normalx + dv2y * normaly;
				
				b1 = (vn1 - cp1.velocityBias) - (manifold.kN11 * a1 + manifold.kN12 * a2);
				b2 = (vn2 - cp2.velocityBias) - (manifold.kN21 * a1 + manifold.kN22 * a2);
				
				//while(true){
				x1 = -(manifold.normalMass11 * b1 + manifold.normalMass12 * b2);
				x2 = -(manifold.normalMass21 * b1 + manifold.normalMass22 * b2);
				
				if(x1 < 0 || x2 < 0)
				{
					x1 = -cp1.normalMass * b1;
					x2 = 0;
					vn1 = 0;
					vn2 = manifold.kN21 * x1 + b2;
					if(x1 < 0 || vn2 < 0)
					{
						x1 = 0;
						x2 = -cp2.normalMass * b2;
						vn1 = manifold.kN12 * x2 + b1;
						vn2 = 0;
						if(x2 < 0 || vn1 < 0)
						{
							x1 = 0;
							x2 = 0;
							vn1 = b1;
							vn2 = b2;
							if(vn1 < 0 || vn2 < 0)
								noSolution = true;
						}
					}
				}
				
				if(!noSolution)
				{
					d1 = x1 - a1;
					d2 = x2 - a2;
					
					p1x = d1 * normalx;
					p1y = d1 * normaly;
					
					p2x = d2 * normalx;
					p2y = d2 * normaly;
					
					v1x -= body1.invMass * (p1x + p2x);
					v1y -= body1.invMass * (p1y + p2y);
					w1 -= body1.invI * ((cp1.r1.x * p1y - cp1.r1.y * p1x) + (cp2.r1.x * p2y - cp2.r1.y * p2x));
					
					v2x += body2.invMass * (p1x + p2x);
					v2y += body2.invMass * (p1y + p2y);
					w2 += body2.invI * ((cp1.r2.x * p1y - cp1.r2.y * p1x) + (cp2.r2.x * p2y - cp2.r2.y * p2x));
					
					cp1.normalImpulse = x1;
					cp2.normalImpulse = x2;
				}

			}
			
			
			//*
			for (j in 0...pCount)
			{
				cp1 = manifold.pointArray[j];
				r1x = cp1.r1.x;
				r1y = cp1.r1.y;
				r2x = cp1.r2.x;
				r2y = cp1.r2.y;
				//relative velocity at contact
				dv1x = v2x - w2 * r2y - (v1x - w1 * r1y);
				dv1y = v2y + w2 * r2x - (v1y + w1 * r1x);
				vt = dv1x * tangentx + dv1y * tangenty;
				lambda = cp1.tangentMass * -vt;
				maxFriction = cp1.friction * cp1.normalImpulse;
				t = cp1.tangentImpulse + lambda;
				min = t < maxFriction ? t : maxFriction;
				newImpulse = (min > -maxFriction) ? min : -maxFriction;
				lambda = newImpulse - cp1.tangentImpulse;
				
				cp1.tangentImpulse = newImpulse;
				
				p1x = lambda * tangentx;
				p1y = lambda * tangenty;
				
				//*
				v1x -= body1.invMass * p1x;
				v1y -= body1.invMass * p1y;
				w1 -= body1.invI * (r1x * p1y - r1y * p1x);
				
				v2x += body2.invMass * p1x;
				v2y += body2.invMass * p1y;
				w2 += body2.invI * (r2x * p1y - r2y * p1x);//*/

			}//*/
			
			body1.velocity.x = v1x;
			body1.velocity.y = v1y;
			body2.velocity.x = v2x;
			body2.velocity.y = v2y;
			body1.angularVelocity = w1;
			body2.angularVelocity = w2;

		}

	}
	
	public function solvePositionConstraints():Bool
	{
		var m:Manifold;
		var body1:RigidBody;
		var body2:RigidBody;
		var normalx:Float;
		var normaly:Float;
		
		var cp1:ContactPoint;
		var cp2:ContactPoint;
		
		var r11x:Float;
		var r11y:Float;
		var r12x:Float;
		var r12y:Float;
		var r21x:Float;
		var r21y:Float;
		var r22x:Float;
		var r22y:Float;
		
		var separation1:Float;
		var separation2:Float;
		
		var minSeparation:Float = 0;
		
		var min:Float;
		var c1:Float;
		var c2:Float;
		
		var f1:Float;
		var f2:Float;
		
		var x1:Float;
		var x2:Float;
		
		var dImpulse:Float;
		var impulse1x:Float;
		var impulse1y:Float;
		var impulse2x:Float;
		var impulse2y:Float;
		
		var t:Float;
		
		var invMass1:Float;
		var invMass2:Float;
		var invI1:Float;
		var invI2:Float;
		
		var i:Int;
		
		for ( i in 0...manifoldCount)
		{
			m = manifoldArray[i];
			body1 = m.body1;
			body2 = m.body2;
			invMass1 = m.invMass1;
			invMass2 = m.invMass2;
			invI1 = m.invI1;
			invI2 = m.invI2;
			
			m.reevaluate();
			normalx = m.normal.x;
			normaly = m.normal.y;
			
			if (m.pointCount == 2)
			{
				cp1 = m.point1;
				cp2 = m.point2;
				
				r11x = cp1.position.x - body1.worldCenterOfMass.x;
				r11y = cp1.position.y - body1.worldCenterOfMass.y;
				
				r21x = cp2.position.x - body1.worldCenterOfMass.x;
				r21y = cp2.position.y - body1.worldCenterOfMass.y;
				
				r12x = cp1.position.x - body2.worldCenterOfMass.x;
				r12y = cp1.position.y - body2.worldCenterOfMass.y;
				
				r22x = cp2.position.x - body2.worldCenterOfMass.x;
				r22y = cp2.position.y - body2.worldCenterOfMass.y;
				
				separation1 = cp1.separation;
				
				if(separation1 < body1.minSeparation)
					body1.minSeparation = separation1;
				if(separation1 < body2.minSeparation)
					body2.minSeparation = separation1;
				
				minSeparation = minSeparation < separation1 ? minSeparation : separation1;
				separation1 += linearSlop;
				t = separation1;
				//t = t < 0 ? t : 0;
				t = (t > -maxLinearCorrection) ? t : -maxLinearCorrection;
				c1 = contactBaumgarte * t;
				
				separation2 = cp2.separation;
				if(separation2 < body1.minSeparation)
					body1.minSeparation = separation2;
				if(separation2 < body2.minSeparation)
					body2.minSeparation = separation2;
					
					
				minSeparation = minSeparation < separation2 ? minSeparation : separation2;
				separation2 += linearSlop;
				t = separation2;
				//t = t < 0 ? t : 0;
				t = (t > -maxLinearCorrection) ? t : -maxLinearCorrection;
				c2 = contactBaumgarte * t;
				
				if (c1 > 0) {
					if (c2 > 0)
						continue;
				}
				
				f1 = c1;
				f2 = c2;
				
				x1 = -(m.equalizedMass11 * c1 + m.equalizedMass12 * c2);
				x2 = -(m.equalizedMass21 * c1 + m.equalizedMass22 * c2);
				
				if(x1 < 0 || x2 < 0)
				{
					x1 = -cp1.equalizedMass * f1;
					x2 = 0;
					c1 = 0;
					c2 = m.kE12 * x1 + f2;
					if(x1 < 0 || c2 < 0)
					{
						x1 = 0;
						x2 = -cp2.equalizedMass * f2;
						c1 = m.kE21 * x2 + f1;
						c2 = 0;
						if(x2 < 0 || c1 < 0)
						{
							x1 = 0;
							x2 = 0;
							c1 = f1;
							c2 = f2;
						}
					}
				}
				
				impulse1x = x1 * normalx;
				impulse1y = x1 * normaly;
				
				impulse2x = x2 * normalx;
				impulse2y = x2 * normaly;
				
				if(!body1.isStatic)
				{
					body1.position.x -= (impulse1x + impulse2x) * invMass1;
					body1.position.y -= (impulse1y + impulse2y) * invMass1;
					body1.setRotation(body1.getRotation() - ((r11x * impulse1y - r11y * impulse1x) + (r21x * impulse2y - r21y * impulse2x)) * invI1);
					body1.synchronizeTransform();
				}
				if(!body2.isStatic)
				{
					body2.position.x += (impulse1x + impulse2x) * invMass2;
					body2.position.y += (impulse1y + impulse2y) * invMass2;
					body2.setRotation(body2.getRotation() + ((r12x * impulse1y - r12y * impulse1x) + (r22x * impulse2y - r22y * impulse2x)) * invI2);
					body2.synchronizeTransform();
				}
			}else
			{
				cp1 = m.useSecondPoint ? m.point2 : m.point1;
				r11x = cp1.position.x - body1.worldCenterOfMass.x;
				r11y = cp1.position.y - body1.worldCenterOfMass.y;
				r12x = cp1.position.x - body2.worldCenterOfMass.x;
				r12y = cp1.position.y - body2.worldCenterOfMass.y;
				
				separation1 = cp1.separation;
				if(separation1 < body1.minSeparation)
					body1.minSeparation = separation1;
				if(separation1 < body2.minSeparation)
					body2.minSeparation = separation1;
				minSeparation = (minSeparation < separation1) ? minSeparation : separation1;
				//float32 C = baumgarte * b2Clamp(separation + b2_linearSlop, -b2_maxLinearCorrection, 0.0f);
				t = separation1 + linearSlop;
				if (t > 0)
					continue;
				min = t;
				c1 = contactBaumgarte * ((min > -maxLinearCorrection) ? min : -maxLinearCorrection);
				
				dImpulse = -c1 * cp1.equalizedMass;
				
				
				impulse1x = dImpulse * normalx;
				impulse1y = dImpulse * normaly;
				if(!body1.isStatic)
				{
					body1.position.x -= impulse1x * invMass1;
					body1.position.y -= impulse1y * invMass1;
					body1.setRotation(body1.getRotation()- (r11x * impulse1y - r11y * impulse1x) * invI1);
					body1.synchronizeTransform();
				}
				if(!body2.isStatic)
				{
					body2.position.x += impulse1x * invMass2;
					body2.position.y += impulse1y * invMass2;
					body2.setRotation(body2.getRotation() + (r12x * impulse1y - r12y * impulse1x) * invI2);
					body2.synchronizeTransform();
				}
			}
		}
		return minSeparation >= -linearSlop * 1.5;
	}
}