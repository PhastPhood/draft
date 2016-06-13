package game.characters.kanye;
import draft.math.MathConstants;
import draft.math.Vector2D;
import game.characters.kanye.KanyeState;
import game.GameSettings;

/**
 * ...
 * @author asdf
 */

class KanyeRunningState extends KanyeState
{

	private static inline var BOOMBOX_MAX_ANGLE:Float = 7;
	private static inline var BOOMBOX_MIN_ANGLE:Float = 0;
	private static inline var BOOMBOX_MAX_FRAME:Int = 50;
	private static inline var BOOMBOX_MIN_FRAME:Int = 12;
	
	public var moveDirection:Vector2D;
	public var movementForce:Vector2D;
	public var timeAdjustmentFrame:Int;
	
	public function new(kanye:KanyeCharacter) 
	{
		super(kanye);
		visibleSpriteArray[1] = character.runningSprite;
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
		
		if (character.leftKeyDown && character.rightKeyDown || !character.rightKeyDown && !character.leftKeyDown)
		{
			character.switchState(character.stillState);
			character.stillState.preStep();
			return;
		}
		
		if (character.leftKeyDown)
		{
			moveDirection.x = character.groundNormal.y;
			moveDirection.y = -character.groundNormal.x;
		}else
		{
			moveDirection.x = -character.groundNormal.y;
			moveDirection.y = character.groundNormal.x;
		}
		
		var currentDVelocity:Float = character.body.velocity.x * moveDirection.x + character.body.velocity.y * moveDirection.y;
		var ds:Float = 0;
		if ( currentDVelocity < -GameSettings.KANYE_STILL_SPEED_TOLERANCE)
		{
			ds = GameSettings.KANYE_RUNNING_SPEED_INCREASE + GameSettings.KANYE_SLIDING_SPEED_DECREASE;
		}else
		{
			ds = GameSettings.KANYE_MAX_RUNNING_SPEED - currentDVelocity;
			if (ds < 0)
			{
				
			}else if (ds > GameSettings.KANYE_RUNNING_SPEED_INCREASE)
			{
				ds = GameSettings.KANYE_RUNNING_SPEED_INCREASE * (ds/GameSettings.KANYE_MAX_RUNNING_SPEED * 0.4 + 0.6);
			}
		}
		
		movementForce.x = moveDirection.x * ds * character.forceMultiplier;
		movementForce.y = moveDirection.y * ds * character.forceMultiplier;
		character.body.applyForce(movementForce);
		
	}
	
	override public function postStep():Void 
	{
		var currentDVelocity:Float = character.body.velocity.x * moveDirection.x + character.body.velocity.y * moveDirection.y;
		
		if (currentDVelocity < -2 * GameSettings.KANYE_STILL_SPEED_TOLERANCE)
		{
			character.switchState(character.slidingState);
			character.slidingState.postStep();
			return;
		}
		
		
		if (character.rightKeyDown)
		{
			character.direction = 1;
		}else
		{
			character.direction = -1;
		}
		
		if (timeAdjustmentFrame > 4)
		{
			character.runningSprite.currentFrame += 1;
			character.runningSprite.updateVertexBuffer();
			timeAdjustmentFrame = 0;
		}
		timeAdjustmentFrame++;
		super.postStep();
	}
	
	override public function startState(prevState:KanyeState):Void 
	{
		super.startState(prevState);
		
		timeAdjustmentFrame = 0;
		character.runningSprite.currentFrame = 0;
	}
	
}