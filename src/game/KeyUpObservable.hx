package game;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import flash.events.KeyboardEvent;
import flash.Lib;

/**
 * ...
 * @author asdf
 */

class KeyUpObservable implements IObservable
{

	public var observerArray:Array<IObserver>;
	public function new() 
	{
		observerArray = new Array<IObserver>();
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyPressed, false, 0, true);
	}
	
	public function attach(o:IObserver):Void
	{
		observerArray.push(o);
	}
	
	public function detach(o:IObserver):Void
	{
		observerArray.remove(o);
	}
	
	private function keyPressed(e:KeyboardEvent):Void
	{
		notify(UserEvent.KEY_UP, e.keyCode);
	}
	
	public function notify(type:Int, data:Dynamic = null):Void
	{
		for (o in observerArray)
		{
			o.update(type, this, data);
		}
	}
}