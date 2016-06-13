package game;
import draft.math.Vector2D;
import game.characters.kanye.KanyeCharacter;

/**
 * ...
 * @author asdf
 */

class CameraControl 
{

	public var camera:Camera2D;
	public var player:KanyeCharacter;
	
	public var focus:Vector2D;
	public var goalFocus:Vector2D;
	
	public function new(camera:Camera2D, player:KanyeCharacter) 
	{
		this.camera = camera;
		this.player = player;
		focus = new Vector2D();
		goalFocus = new Vector2D();
	}
	
	public function positionCamera():Void
	{
		if (player == null)
			return;
			
		var vOffset:Float = player.body.velocity.y / GameSettings.KANYE_VELOCITY_Y_MAX;
		var vOffset2:Float = vOffset < 0 ? -vOffset : vOffset;
		vOffset *= vOffset2;
		//vOffset *= 0.5;
		
		goalFocus.x = player.body.position.x + player.direction * GameSettings.CAMERA_FOCUS_DISTANCE_X;
		goalFocus.y = player.body.position.y;// + vOffset * GameSettings.CAMERA_FOCUS_DISTANCE_X - 30;
		
		var dX:Float = goalFocus.x - focus.x;
		var dY:Float = goalFocus.y - focus.y;
		
		var v:Float = player.body.velocity.x > 0 ? player.body.velocity.x : 0;
		
		if (dX > GameSettings.CAMERA_FOCUS_SPEED_X + v * 1.2 * GameSettings.INVERSE_FRAMERATE)
		{
			dX = GameSettings.CAMERA_FOCUS_SPEED_X + v * 1.2 * GameSettings.INVERSE_FRAMERATE;
		}
		
		v = player.body.velocity.x < 0 ? player.body.velocity.x : 0;
		
		if (dX < -GameSettings.CAMERA_FOCUS_SPEED_X + v * 1.2 * GameSettings.INVERSE_FRAMERATE)
		{
			dX = -GameSettings.CAMERA_FOCUS_SPEED_X + v * 1.2 * GameSettings.INVERSE_FRAMERATE;
		}
		
		v = player.body.velocity.y > 0 ? player.body.velocity.y : 0;
		
		if (dY > GameSettings.CAMERA_FOCUS_SPEED_Y + v * 1.2 * GameSettings.INVERSE_FRAMERATE)
		{
			dY = GameSettings.CAMERA_FOCUS_SPEED_Y + v * 1.2 * GameSettings.INVERSE_FRAMERATE;
		}
		
		v = player.body.velocity.y < 0 ? player.body.velocity.y : 0;
		
		if (dY < -GameSettings.CAMERA_FOCUS_SPEED_Y + v * 1.2 * GameSettings.INVERSE_FRAMERATE)
		{
			dY = -GameSettings.CAMERA_FOCUS_SPEED_Y + v * 1.2 * GameSettings.INVERSE_FRAMERATE;
		}
		
		focus.x += dX;
		focus.y += dY;
		
		var centerX:Float = camera.viewPort.x + camera.viewPort.width * 0.5;
		var centerY:Float = camera.viewPort.y + camera.viewPort.height * 0.5;
		
		camera.viewPort.x -= (centerX - focus.x) / GameSettings.CAMERA_FOCUS_X;
		camera.viewPort.y -= (centerY - focus.y) / (GameSettings.CAMERA_FOCUS_Y);// / (vOffset * 0.3 + 1));
		
	}
	
	
	
}