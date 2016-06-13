package game.characters.kanye;
import draft.math.MathApprox;
import draft.math.MathConstants;
import draft.math.Vector2D;
import game.GameSettings;

/**
 * ...
 * @author asdf
 */

class KanyeJumpingState extends KanyeState
{

	public var jumpFrameCount:Int;
	
	public var moveDirection:Vector2D;
	public var movementForce:Vector2D;
	
	private var forceMultiplier:Float;
	public var gravityDecreaseVector:Vector2D;
	
	public var jumpMaxFrameCount:Int;
	
	public function new(kanye:KanyeCharacter) 
	{
		super(kanye);
		visibleSpriteArray[1] = character.jumpingSprite;
		moveDirection = new Vector2D();
		movementForce = new Vector2D();
		
		gravityDecreaseVector = new Vector2D(0, -GameSettings.KANYE_JUMP_GRAVITY_DECREASE * character.body.mass * GameSettings.PHYSICS_STEP_COUNT);
		
		jumpFrameCount = 0;
		jumpMaxFrameCount = Std.int(GameSettings.KANYE_JUMP_TIME / GameSettings.INVERSE_FRAMERATE);
	}
	
	override public function preStep():Void 
	{
		super.preStep();
		
		if (character.standablePointCount > 0 && jumpFrameCount > 2)
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
		
		if (jumpFrameCount > jumpMaxFrameCount || !character.jumpKeyDown)
		{
			character.switchState(character.fallingState);
			character.fallingState.preStep();
			return;
		}
		
		character.body.applyForce(gravityDecreaseVector);
		
		jumpFrameCount++;
		
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
		
		jumpFrameCount = 0;
		character.jumpReset = false;
		
		var jumpDirectionX:Float = character.groundNormal.x;
		var jumpDirectionY:Float = character.groundNormal.y - 1;
		
		var invL:Float = MathApprox.invSqrt(jumpDirectionX * jumpDirectionX + jumpDirectionY * jumpDirectionY);
		jumpDirectionX *= invL;
		jumpDirectionY *= invL;
		
		var vDecrease:Float = character.body.velocity.y;
		//vDecrease = vDecrease > 0 ? 0 : vDecrease;
		
		var jumpVector:Vector2D = new Vector2D();
		jumpVector.x = jumpDirectionX * GameSettings.KANYE_JUMP_INITIAL_SPEED * character.forceMultiplier;
		jumpVector.y = jumpDirectionY * GameSettings.KANYE_JUMP_INITIAL_SPEED * character.forceMultiplier - (vDecrease * character.forceMultiplier);
		
		character.body.applyForce(jumpVector);

	}	
}