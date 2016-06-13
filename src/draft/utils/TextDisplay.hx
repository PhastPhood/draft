package draft.utils;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.text.TextField;

/**
 * ...
 * @author asdf
 */

class TextDisplay extends StatMonitor
{
	private var text:TextField;
	private var rectangle:Sprite;
	
	public function new(initialText:String) 
	{
		super();
		
		text = new TextField();
		text.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#00FFFF'>" + initialText + "</FONT>";
	}
	
	public override function init():Void
	{
		h = Std.int(text.textHeight + 4);
		
		rectangle = new Sprite();
		rectangle.graphics.beginFill(0xFFFFFF, 1);
		rectangle.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		rectangle.graphics.drawRect(0, 0, w, h);
		addChild(rectangle);
		
		text.width = w;
		text.selectable = false;
		text.mouseEnabled = false;
		text.condenseWhite = true;
		text.multiline = true;
		text.x = 2;
		text.y = 2;
		addChild(text);
	}
	
	public function setText(t:String):Void
	{
		text.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#00FFFF'>" + t + "</FONT>";
		h = Std.int(text.textHeight + 4);
		rectangle.graphics.clear();
		rectangle.graphics.beginFill(0xFFFFFF, 1);
		rectangle.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		rectangle.graphics.drawRect(0, 0, w, h);
	}
	
}