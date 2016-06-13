/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.dynamics;
import draft.physics.dynamics.contacts.Contact;
import draft.physics.dynamics.contacts.solvers.ContactSolver;
import draft.physics.dynamics.contacts.solvers.SISolver;

class Island 
{
	
	public var bodyArray:Array<RigidBody>;
	public var bodyCount:Int;
	
	public var contactArray:Array<Contact>;
	public var contactCount:Int;
	
	public var contactSolver:ContactSolver;
	
	public var allowSleep:Bool;
	public var sleepIdleTime:Float;
	public var linearSleepTolerance:Float;
	public var linearSleepToleranceSquared:Float;
	public var angularSleepTolerance:Float;
	public var separationSleepTolerance:Float;

	public function new() 
	{
		bodyArray = new Array<RigidBody>();
		contactArray = new Array<Contact>();
		
		contactSolver = new SISolver();
		
		contactSolver.bodyArray = bodyArray;
		contactSolver.contactArray = contactArray;
		
		allowSleep = false;
		linearSleepTolerance = 0.4;
		linearSleepToleranceSquared = linearSleepTolerance * linearSleepTolerance;
		angularSleepTolerance = 2 * Math.PI / 180;
		separationSleepTolerance = 2;
		
		sleepIdleTime = 0.5;
		
		
	}
	
	public function reset():Void
	{
		bodyCount = 0;
		contactCount = 0;
	}
	
	public function solve(dt:Float, iterations:Int):Void
	{
		contactSolver.bodyCount = bodyCount;
		contactSolver.contactCount = contactCount;
		contactSolver.solve(dt, iterations);
		
		if (allowSleep)
		{
			var minSleepTime:Float = Math.POSITIVE_INFINITY;
			var body:RigidBody;
			for (i in 0...bodyCount)
			{
				body = bodyArray[i];
				if (body.isStatic)
					continue;
				if (body.allowSleep == false ||
					body.angularVelocity > angularSleepTolerance ||
					body.velocity.x * body.velocity.x + body.velocity.y * body.velocity.y > linearSleepToleranceSquared ||
					body.minSeparation < -separationSleepTolerance)
				{
					body.sleepTime = 0;
					minSleepTime = 0;
				}else
				{
					body.sleepTime += dt;
					minSleepTime = body.sleepTime < minSleepTime ? body.sleepTime : minSleepTime;
				}
			}
			
			if (minSleepTime > sleepIdleTime)
			{
				for (i in 0...bodyCount)
				{
					//trace(minSleepTime + ", " + sleepIdleTime);
					body = bodyArray[i];
					body.putToSleep();
				}
			}
		}
	}
	
}