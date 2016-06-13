package game.characters.kanye;
import draft.math.MathConstants;
import draft.math.Vector2D;

/**
 * ...
 * @author asdf
 */

class KanyeFallingState extends KanyeState
{

	public var moveDirection:Vector2D;
	public var movementForce:Vector2D;
	
	public function new(kanye:KanyeCharacter) 
	{
		super(kanye);
		visibleSpriteArray[1] = character.jumpingSprite;
		moveDirection = new Vector2D();
		movementForce = new Vector2D();
	}
	
	override public function preStep():Void 
	{
		super.preStep();
		
		if (character.standablePointCount > 0)
		{
			if (character.rightKeyDown && !character.leftKeyDown || character.leftKeyDown && !character.rightKeyDown)
			{
				character.switchState(character.runningState);
				character.runningState.preStep();
				return;
			}else
			{
				character.switchState(character.stillState);
				character.stillState.preStep();
				return;
			}
		}
		
		if (character.leftKeyDown)
		{
			moveDirection.x = -1;
			moveDirection.y = 0;
		}else if (character.rightKeyDown)
		{
			moveDirection.x = 1;
			moveDirection.y = 0;
		}
		
		if (character.rightKeyDown && !character.leftKeyDown || character.leftKeyDown && !character.rightKeyDown)
		{
		
			var currentDVelocity:Float = moveDirection.x * character.body.velocity.x;
			var ds:Float = 0;
			
			ds = GameSettings.KANYE_MAX_RUNNING_SPEED - currentDVelocity;
			if (ds < 0)
			{
				
			}else if (ds > GameSettings.KANYE_FALLING_SPEED_INCREASE)
			{
				ds = GameSettings.KANYE_FALLING_SPEED_INCREASE;
			}
			
			movementForce.x = moveDirection.x * ds * character.forceMultiplier;
			movementForce.y = moveDirection.y * ds * character.forceMultiplier;
			character.body.applyForce(movementForce);
		}
		
	}
	
	override public function postStep():Void 
	{
		var currentDVelocity:Float = character.body.velocity.x * moveDirection.x;
		
		if (character.rightKeyDown)
		{
			character.direction = 1;
		}else if (character.leftKeyDown)
		{
			character.direction = -1;
		}
		
		super.postStep();
	}
	
	override public function startState(prevState:KanyeState):Void 
	{
		super.startState(prevState);
	}

	
}