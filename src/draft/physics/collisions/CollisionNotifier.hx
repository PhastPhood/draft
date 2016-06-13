package draft.physics.collisions;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.physics.collisions.shapes.CollisionShape;

/**
 * ...
 * @author asdf
 */

class CollisionNotifier implements IObservable
{
	public var observerArray:Array<IObserver>;
	public var source:CollisionShape;
	public var collisionData:CollisionData;
	
	public function new(s:CollisionShape) 
	{
		observerArray = new Array<IObserver>();
		source = s;
		collisionData = new CollisionData();
	}
	
	public function attach(o:IObserver):Void
	{
		observerArray.push(o);
	}
	
	public function detach(o:IObserver):Void
	{
		observerArray.remove(o);
	}
	
	public function notify(type:Int, data:Dynamic = null):Void
	{
		for (o in observerArray)
		{
			o.update(type, this, data);
		}
	}
	
	public function free():Void
	{
		source = null;
		for (o in observerArray)
			o = null;
		observerArray = null;
		collisionData.shape1 = null;
		collisionData.shape2 = null;
		collisionData = null;
	}
	
}