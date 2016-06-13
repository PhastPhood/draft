package;
import flash.display.BitmapData;

/**
 * ...
 * @author asdf
 */

class TemporaryGraphics 
{

	public var graphicsArray:Array<BitmapData>;
	public function new() 
	{
		graphicsArray = new Array<BitmapData>();
		//0
		graphicsArray.push(new DeleteThisLater());
	}
	
}

class DeleteThisLater extends BitmapData {public function new(){super(0,0);}}
