package draft.patterns;

/**
 * ...
 * @author asdf
 */

interface IObserver 
{
	function update(type:Int, source:IObservable, data:Dynamic):Void;
}