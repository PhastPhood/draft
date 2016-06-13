package draft.patterns;

/**
 * ...
 * @author asdf
 */

interface IObservable 
{
	//COCKSUCKER
	function attach(o:IObserver):Void;
	function detach(o:IObserver):Void;
	function notify(type:Int, data:Dynamic = null):Void;
	
}