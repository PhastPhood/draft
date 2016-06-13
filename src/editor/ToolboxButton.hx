package editor;
import flash.display.Sprite;
import flash.text.TextField;

/**
 * ...
 * @author asdf
 */

class ToolboxButton extends Sprite
{

	public var text:TextField;
	public var label:String;
	public function new(label:String) 
	{
		super();
		text = new TextField();
		text.selectable = false;
		text.mouseEnabled = false;
		text.condenseWhite = true;
		text.x = 2;
		text.y = 3;
		text.width = 70;
		text.height = 16;
		addChild(text);
		
		this.label = label;
		drawUnselected();
	}
	
	public function drawUnselected():Void
	{
		graphics.clear();
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0xFFFFFF, 1);
		graphics.drawRect(0, 0, 70, 18);
		text.htmlText = "<FONT FACE = '_sans' SIZE = '8' COLOR = '#00FFFF'>" + label + "</FONT>";
		
	}
	
	public function drawSelected():Void
	{
		graphics.clear();
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0x00FFFF, 1);
		graphics.drawRect(0, 0, 70, 18);
		text.htmlText = "<FONT FACE = '_sans' SIZE = '8' COLOR = '#FFFFFF'>" + label + "</FONT>";
		
	}
	
}