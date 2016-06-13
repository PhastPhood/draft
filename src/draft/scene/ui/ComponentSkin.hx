package draft.scene.ui;
import draft.graphics.BatchTexture;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * ...
 * @author asdf
 */

class ComponentSkin 
{

	public var texture:BitmapData;
	public var boundaryArray:Array<Rectangle>;
	
	public function new(t:BitmapData, ba:Array<Rectangle>) 
	{
		texture = t;
		boundaryArray = ba;
	}
	
}