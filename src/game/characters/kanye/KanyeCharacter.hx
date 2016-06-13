package game.characters.kanye;
import draft.graphics.MolehillAnimatedSprite;
import draft.graphics.MolehillSprite;
import draft.math.MathApprox;
import draft.math.MathConstants;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.physics.collisions.CollisionData;
import draft.physics.collisions.shapes.CircleShape;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.ContactPoint;
import draft.physics.dynamics.contacts.Manifold;
import draft.physics.PhysicsEngine;
import draft.physics.PhysicsEvent;
import flash.accessibility.Accessibility;
import flash.geom.Rectangle;
import game.characters.DynamicEntity;
import game.Game2D;
import game.GameLayer;
import game.GameSettings;
import game.UserEvent;

/**
 * ...
 * @author asdf
 */

class KanyeCharacter extends DynamicEntity implements IObservable implements IObserver
{
	public static inline var SCALE:Float = 0.35;
	
	public static inline var RUNNING_MAX_LEAN:Float = -0.1;
	public static inline var COLLISION_RADIUS:Float = 66 * SCALE;
	public static inline var CAPSULE_RADIUS:Float = 64 * SCALE;
	public static inline var CAPSULE_HEIGHT:Float = 275 * SCALE;
	public static inline var ROTATION_TOLERANCE:Float = 0.05;
	
	public var stillState:KanyeStillState;
	public var runningState:KanyeRunningState;
	public var slidingState:KanyeSlidingState;
	public var fallingState:KanyeFallingState;
	public var jumpingState:KanyeJumpingState;
	
	public var direction:Float;
	
	public var rotation:Float;
	public var spriteRotationMatrix:RotationMatrix2D;
	
	public var groundNormal:Vector2D;
	
	public var currentState:KanyeState;
	
	public var standingSprite:MolehillSprite;
	public var runningSprite:MolehillAnimatedSprite;
	public var jumpingSprite:MolehillSprite;
	
	public var observerArray:Array<IObserver>;
	
	public var leftKeyDown:Bool;
	public var rightKeyDown:Bool;
	public var jumpKeyDown:Bool;
	public var jumpReset:Bool;
	
	public var leanMatrix:RotationMatrix2D;
	public var headOffset:Vector2D;
	public var armOffset:Vector2D;
	
	public var rightInFront:Bool;
	//public var contactPointArray:Array<ContactPoint>;
	
	public var manifoldArray:Array<Manifold>;
	public var manifoldCount:Int;
	//public var contactPointCount:Int;
	public var standablePointCount:Int;
	
	public var sensorShape:CollisionShape;
	private var torqueMultiplier:Float;
	
	private var previousRotation:Float;
	private var previousDirection:Int;
	private var rotationFrameCount:Int;

	public function new(data:KanyeDefinition, l:GameLayer) 
	{
		super(data, l);
		
		sensorShape = body.shapeList;
		
		sensorShape.enableNotifications = true;
		sensorShape.notifier.attach(this);
		
		manifoldArray = new Array<Manifold>();
		manifoldCount = 0;
		
		observerArray = new Array<IObserver>();
		leanMatrix = new RotationMatrix2D();
		
		spriteRotationMatrix = new RotationMatrix2D();
		rotation = 0;
		
		var walker:MolehillSprite = spriteList;
		standingSprite = cast(walker, MolehillSprite);
		walker = walker.next;
		runningSprite = cast(walker, MolehillAnimatedSprite);
		walker = walker.next;
		jumpingSprite = cast(walker, MolehillSprite);
		
		entityType = DynamicEntity.KANYE;
		
		stillState = new KanyeStillState(this);
		slidingState = new KanyeSlidingState(this);
		runningState = new KanyeRunningState(this);
		fallingState = new KanyeFallingState(this);
		jumpingState = new KanyeJumpingState(this);
		
		groundNormal = new Vector2D(0, -1);
		
		currentState = stillState;
		direction = 1;
		currentState.startState(stillState);
		
		leftKeyDown = false;
		rightKeyDown = false;
		jumpKeyDown = false;
		jumpReset = true;
		
		l.game.keyDownControl.attach(this);
		l.game.keyUpControl.attach(this);
		
		rightInFront = true;
		
		torqueMultiplier = body.I / layer.game.dt * layer.game.physicsStepCount;
		previousRotation = 0;
	}
	
	public function notify(type:Int, data:Dynamic = null):Void
	{
		currentState.update(type, this, data);
		for (o in observerArray)
			o.update(type, this, data);
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		if (type == UserEvent.KEY_DOWN)
		{
			if (data == GameSettings.RIGHT_KEY)
				rightKeyDown = true;
			if (data == GameSettings.LEFT_KEY)
				leftKeyDown = true;
			if (data == GameSettings.JUMP_KEY)
				jumpKeyDown = true;
			notify(UserEvent.KEY_DOWN, true);
		}else if (type == UserEvent.KEY_UP)
		{
			if (data == GameSettings.RIGHT_KEY)
				rightKeyDown = false;
			if (data == GameSettings.LEFT_KEY)
				leftKeyDown = false;
			if (data == GameSettings.JUMP_KEY)
			{
				jumpReset = true;
				jumpKeyDown = false;
			}
			notify(UserEvent.KEY_UP, false);
		}else if (type == PhysicsEvent.COLLIDE)
		{
			var cData:CollisionData = cast(data, CollisionData);
			manifoldArray[manifoldCount] = cData.manifold;
			manifoldCount++;
		}
	}
	
	override public function updateSprites():Void 
	{
		super.updateSprites();
		var dx:Float;
		var dy:Float;
		
		var d:Int;
		
		var effectiveBodyRotation:Float = (1 * previousRotation + 4 * body.getRotation()) / 5;
		var dR:Float = effectiveBodyRotation - previousRotation;
		if (dR < 0)
		{
			dR = -dR;
			d = -1;
			if (dR > ROTATION_TOLERANCE)
				effectiveBodyRotation = previousRotation - ROTATION_TOLERANCE;
		}else
		{
			d = 1;
			if (dR > ROTATION_TOLERANCE)
				effectiveBodyRotation = previousRotation + ROTATION_TOLERANCE;
		}
		
		if (d != previousDirection)
		{
			rotationFrameCount = 0;
		}
		
		if (rotationFrameCount < 3)
		{
			effectiveBodyRotation = previousRotation;
		}
		
		rotationFrameCount++;
		
		previousDirection = d;
		
		spriteRotationMatrix.setAngle(effectiveBodyRotation * direction + rotation * MathConstants.DEGREES_TO_RADIANS);
		
		for (spriteWalker in visibleSpriteArray)
		{
			if (spriteWalker == null)
				continue;
			dx = direction * spriteWalker.localPosition.x * spriteRotationMatrix.i1j1 + spriteWalker.localPosition.y * direction * spriteRotationMatrix.i1j2;
			dy = direction * spriteWalker.localPosition.x * direction * spriteRotationMatrix.i2j1 + spriteWalker.localPosition.y * spriteRotationMatrix.i2j2;
			spriteWalker.position.x = body.worldCenterOfMass.x + dx;
			spriteWalker.position.y = body.worldCenterOfMass.y + dy;
			spriteWalker.rotation = effectiveBodyRotation * MathConstants.RADIANS_TO_DEGREES * direction + rotation + spriteWalker.localRotation;
			spriteWalker.update();
		}
		
		previousRotation = effectiveBodyRotation;
	}
	
	public function updatePhysicsInformation():Void
	{
		var nx:Float = 0;
		var ny:Float = 0;
		standablePointCount = 0;
		groundNormal.x = body.orientation.i2j1;
		groundNormal.y = -body.orientation.i1j1;
		var m:Manifold;
		var normalx:Float;
		var normaly:Float;
		var invL:Float = 0;
		for (i in 0...manifoldCount)
		{
			m = manifoldArray[i];
			/*radiusV.x = cp.position.x - sensorShape.position.x;
			radiusV.y = cp.position.y - sensorShape.position.y;
			
			invL = MathApprox.invSqrt(radiusV.x * radiusV.x + radiusV.y * radiusV.y);
			radiusV.x *= invL;
			radiusV.y *= invL;
			//trace(radiusV);
			if (radiusV.y < 0.5 && radiusV.y > -0.5)
				continue;
			nx -= radiusV.x;
			ny -= radiusV.y;*/
			
			normalx = -m.normal.x;
			normaly = -m.normal.y;
			
			if (m.body2 == sensorShape.body)
			{
				normalx = -normalx;
				normaly = -normaly;
			}
			
			if (normaly < 0.5 && normaly > -0.5)
				continue;
				
			nx += normalx;
			ny += normaly;
			
			standablePointCount++;
		}
		if (nx == 0 && ny == 0)
		{
			ny = -1;
		}else
		{
			invL = MathApprox.invSqrt(nx * nx + ny * ny);
			nx *= invL;
			ny *= invL;
		}
		
		var goalRV = ((Math.atan2(ny, nx) - Math.PI * 0.5) * 0.5 + Math.PI * 0.5) - body.getRotation();
		//var goalRV = -body.getRotation();
		var multiplier:Float = 8 * goalRV / Math.PI;
		multiplier = multiplier < 0 ? -multiplier : multiplier;
		if (multiplier > 1)
			multiplier = 1;
		multiplier *= 0.2;
		multiplier += 0.8;
		goalRV /= layer.game.dt * GameSettings.PHYSICS_STEP_COUNT;
		
		
		/*if (goalRV > GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE)
		{
			goalRV = GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE;
		}else if (goalRV < -GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE)
		{
			goalRV = -GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE;
		}*/
		
		//trace(goalRV);
		//trace(body.angularVelocity);
		
		var dR1:Float = goalRV;
		
		if (dR1 > GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE)
		{
			dR1 = GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE * multiplier;
		}else if (dR1 < -GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE)
		{
			dR1 = -GameSettings.KANYE_ROTATIONAL_SPEED_INCREASE * multiplier;
		}
		
		body.applyTorque((dR1 - body.angularVelocity) * torqueMultiplier);
		
		if (body.velocity.y > GameSettings.KANYE_VELOCITY_Y_MAX || body.velocity.y < -GameSettings.KANYE_VELOCITY_Y_MAX)
		{
			body.applyForce(new Vector2D(0, (GameSettings.KANYE_VELOCITY_Y_MAX - body.velocity.y) * forceMultiplier));
		}
		
		if (body.velocity.x > GameSettings.KANYE_VELOCITY_X_MAX || body.velocity.x < -GameSettings.KANYE_VELOCITY_X_MAX)
		{
			body.applyForce(new Vector2D(0, (GameSettings.KANYE_VELOCITY_X_MAX - body.velocity.x) * forceMultiplier));
		}
		
		//body.angularVelocity = goalRV;
		
		///trace(body.getRotation());
		body.synchronizeShapes();
	}
	
	override public function preUpdateEntity():Void 
	{
		super.preUpdateEntity();
		updatePhysicsInformation();
		manifoldCount = 0;
		currentState.preStep();
	}
	
	override public function postUpdateEntity():Void 
	{
		currentState.postStep();
		super.postUpdateEntity();
	}
	
	public function switchState(s:KanyeState):Void
	{
		s.startState(currentState);
		currentState = s;
	}
	
	public function attach(o:IObserver):Void
	{
		observerArray.push(o);
	}
	
	public function detach(o:IObserver):Void
	{
		observerArray.remove(o);
	}
	
}