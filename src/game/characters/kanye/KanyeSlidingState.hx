package game.characters.kanye;
import draft.math.MathConstants;
import draft.math.Vector2D;
import game.GameSettings;

/**
 * ...
 * @author asdf
 */

class KanyeSlidingState extends KanyeState
{

	public var moveDirection:Vector2D;
	public var movementForce:Vector2D;
	
	public function new(kanye:KanyeCharacter) 
	{
		super(kanye);
		
		visibleSpriteArray[1] = character.standingSprite;
		
		moveDirection = new Vector2D();
		movementForce = new Vector2D();
	}
	
	override public function preStep():Void 
	{
		super.preStep();
		
		if (character.standablePointCount == 0)
		{
			character.switchState(character.fallingState);
			character.fallingState.preStep();
			return;
		}
		
		if (character.jumpKeyDown && character.jumpReset)
		{
			character.switchState(character.jumpingState);
			character.jumpingState.preStep();
			return;
		}
		
		if (character.rightKeyDown && !character.leftKeyDown || character.leftKeyDown && !character.rightKeyDown)
		{
			character.switchState(character.runningState);
			character.runningState.preStep();
			return;
		}
		
		moveDirection.x = character.groundNormal.y;
		moveDirection.y = -character.groundNormal.x;
		
		var currentDVelocity:Float = character.body.velocity.x * moveDirection.x + character.body.velocity.y * moveDirection.y;
		
		if (character.groundNormal.x <= GameSettings.KANYE_SLIDING_NORMAL_X && character.groundNormal.x >= -GameSettings.KANYE_SLIDING_NORMAL_X)
		{
			if (currentDVelocity < GameSettings.KANYE_STILL_SPEED_TOLERANCE && currentDVelocity > -GameSettings.KANYE_STILL_SPEED_TOLERANCE)
			{
				character.switchState(character.stillState);
				character.stillState.preStep();
			}
		}
		
		
		if (currentDVelocity < 0)
		{
			moveDirection.x = -moveDirection.x;
			moveDirection.y = -moveDirection.y;
			currentDVelocity = -currentDVelocity;
			character.direction = 1;
		}else
		{
			character.direction = -1;
		}
		
		var maxDecrease:Float = GameSettings.KANYE_SLIDING_SPEED_DECREASE * (-character.groundNormal.y * 0.8 + 0.2);
		if (currentDVelocity > maxDecrease)
		{
			currentDVelocity = maxDecrease;
		}
		
		movementForce.x = -moveDirection.x * currentDVelocity * character.forceMultiplier;
		movementForce.y = -moveDirection.y * currentDVelocity * character.forceMultiplier;
		character.body.applyForce(movementForce);
		
	}
	
	override public function postStep():Void 
	{
		
		var currentDVelocity:Float = character.body.velocity.x * moveDirection.x + character.body.velocity.y * moveDirection.y;
		
		super.postStep();
	}
	
	override public function startState(prevState:KanyeState):Void 
	{
		super.startState(prevState);
	}
	
}