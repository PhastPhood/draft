package game.characters.kanye;
import draft.graphics.MolehillSprite;
import draft.patterns.IObservable;
import draft.patterns.IObserver;

/**
 * ...
 * @author asdf
 */

class KanyeState implements IObserver
{

	public static inline var NO_STATE:Int = 0;
	public static inline var STILL_STATE:Int = 1;
	public static inline var RUNNING_STATE:Int = 2;
	
	public var stateType:Int;
	public var character:KanyeCharacter;
	
	public var visibleSpriteArray:Array<MolehillSprite>;
	
	public function new(kanye:KanyeCharacter)
	{
		stateType = 0;
		character = kanye;
		visibleSpriteArray = new Array<MolehillSprite>();
	}
	
	public function startState(prevState:KanyeState):Void
	{
		character.visibleSpriteArray = visibleSpriteArray;
	}
	
	public function preStep():Void
	{
		
	}
	
	public function postStep():Void
	{
		for (s in visibleSpriteArray)
		{
			if (s != null)
			{
				s.scaleX = character.direction * KanyeCharacter.SCALE;
				s.scaleY = KanyeCharacter.SCALE;
			}
		}
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		
	}
	
}