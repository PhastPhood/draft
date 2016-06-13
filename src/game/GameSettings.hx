package game;
import draft.math.Vector2D;

/**
 * ...
 * @author asdf
 */

class GameSettings 
{

	public static var LEFT_KEY:Int = 37;
	public static var RIGHT_KEY:Int = 39;
	public static var JUMP_KEY:Int = 90;
	
	public static var GRAVITY:Vector2D = new Vector2D(0, 850);
	
	public static inline var KANYE_MAX_RUNNING_SPEED:Float = 330;
	public static inline var KANYE_RUNNING_SPEED_INCREASE:Float = 15;
	public static inline var KANYE_SLIDING_SPEED_DECREASE:Float = 7;
	public static inline var KANYE_STANDING_SPEED_DECREASE:Float = 23;
	public static inline var KANYE_FALLING_SPEED_INCREASE:Float = 10;
	
	public static inline var KANYE_STILL_SPEED_TOLERANCE:Float = 10;
	public static inline var KANYE_SLIDING_NORMAL_X:Float = 0.3;
	
	public static inline var PHYSICS_STEP_COUNT:Int = 2;
	
	public static inline var GROUND_COLLISION_CATEGORY:Int = 0x00000001;
	public static inline var KANYE_COLLISION_CATEGORY:Int = 0x00000010;
	public static inline var ENEMY_COLLISION_CATEGORY:Int = 0x00000100;
	public static inline var SENSOR_COLLISION_CATEGORY:Int = 0x00010000;
	
	public static inline var KANYE_ROTATIONAL_SPEED_INCREASE:Float = 16;
	
	public static inline var CAMERA_FOCUS_X:Float = 12;
	public static inline var CAMERA_FOCUS_Y:Float = 10;
	public static inline var CAMERA_FOCUS_SPEED_X:Float = 2;
	public static inline var CAMERA_FOCUS_SPEED_Y:Float = 2;
	public static inline var CAMERA_FOCUS_DISTANCE_X:Float = 125;
	
	public static inline var INVERSE_FRAMERATE:Float = 1.0 / 60;
	public static inline var PHYSICS_DT:Float = INVERSE_FRAMERATE / PHYSICS_STEP_COUNT;
	
	public static inline var KANYE_JUMP_INITIAL_SPEED:Float = 360;
	public static inline var KANYE_JUMP_GRAVITY_DECREASE:Float = 460;
	public static var KANYE_JUMP_TIME:Float = KANYE_JUMP_INITIAL_SPEED / (GRAVITY.y - KANYE_JUMP_GRAVITY_DECREASE);
	
	public static inline var KANYE_VELOCITY_X_MAX:Float = 600;
	public static inline var KANYE_VELOCITY_Y_MAX:Float = 600;
}