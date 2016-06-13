package editor;

/**
 * ...
 * @author asdf
 */


import flash.display.Sprite;
import flash.events.MouseEvent;
class LayerButton extends Sprite
{
	public var id:Int;
	public var layerVisible:Bool;
	
	public function new(id:Int):Void
	{
		super();
		this.id = id;
		drawVisible();
		drawUnselected();
		layerVisible = true;
	}
	
	public function drawSelected():Void
	{
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0x00FFFF, 1);
		graphics.drawRect(15, 0, 55, 15);
		graphics.endFill();
	}
	
	public function drawUnselected():Void
	{
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0xFFFFFF, 1);
		graphics.drawRect(15, 0, 55, 15);
		graphics.endFill();
		
	}
	
	public function drawVisible():Void
	{
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0x000000);
		graphics.drawRect(0, 0, 15, 15);
		graphics.endFill();
		graphics.lineStyle(0, 0x000000);
		graphics.beginFill(0x00FFFF);
		graphics.drawRect(3.75, 3.75, 7.5, 7.5);
		graphics.endFill();
	}
	
	public function drawInvisible():Void
	{
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0x000000);
		graphics.drawRect(0, 0, 15, 15);
		graphics.endFill();
	}
}