package editor;
import flash.display.Sprite;
import flash.text.TextField;

/**
 * ...
 * @author asdf
 */

class WindowContainer extends Sprite
{

	public var window:Sprite;
	public var labelField:TextField;
	public function new(window:Sprite, label:String) 
	{
		super();
		this.window = window;
		
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.beginFill(0xFFFFFF, 1);
		graphics.drawRect(0, 0, window.width + 10, window.height + 28);
		graphics.endFill();
		graphics.beginFill(0x000000, 1);
		graphics.drawRect(0, 0, window.width + 10, 18);
		addChild(window);
		window.x = 5;
		window.y = 23;
		
		labelField = new TextField();
		labelField.selectable = false;
		labelField.mouseEnabled = false;
		labelField.condenseWhite = true;
		labelField.x = 2;
		labelField.y = 2;
		labelField.width = this.width;
		labelField.height = 16;
		labelField.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#00FFFF'>" + label + "</FONT>";
		addChild(labelField);
	}
	
	
	
}