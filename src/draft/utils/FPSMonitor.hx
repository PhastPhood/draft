/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.RenderingMode;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.xml.XML;
import flash.xml.XMLList;

class FPSMonitor extends StatMonitor
{
	
	private static inline var GRAPH_WIDTH:Int = 70;
	private static inline var GRAPH_HEIGHT:Int = 40;
	
	private var fpsScale:Float;
	
	private var timer:Int;
	private var frameCount:Int;
	private var fps:Int;
	private var ms:Int;
	private var prevMs:Int;
	
	private var rectangle:Sprite;
	private var graphRectangle:Sprite;
	
	private var graph:BitmapData;
	private var graphBitmap:Bitmap;
	
	private var text:TextField;
	 
	private var backgroundRect:Rectangle;
	
	public function new() 
	{
		super();
		h = 65;
	}
	
	public override function init():Void
	{

		
		rectangle = new Sprite();
		rectangle.graphics.beginFill(0xFFFFFF, 1);
		rectangle.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		rectangle.graphics.drawRect(0, 0, w, h);
		addChild(rectangle);
		
		graphRectangle = new Sprite();
		graphRectangle.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		graphRectangle.graphics.drawRect(0, 0, GRAPH_WIDTH + 4, GRAPH_HEIGHT + 4);
		graphRectangle.graphics.lineStyle(1, 0x00FFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		graphRectangle.graphics.drawRect(1, 1, GRAPH_WIDTH + 2, GRAPH_HEIGHT + 2);
		
		rectangle.addChild(graphRectangle);
		graphRectangle.x = w - GRAPH_WIDTH - 2 - 5;
		graphRectangle.y = h - GRAPH_HEIGHT - 2 - 5;
		
		graph = new BitmapData(GRAPH_WIDTH, GRAPH_HEIGHT, false, 0xFFFFFF);
		graphBitmap = new Bitmap(graph);
		rectangle.addChild(graphBitmap);
		graphBitmap.x = w - GRAPH_WIDTH - 5;
		graphBitmap.y = h - GRAPH_HEIGHT - 5;
		
		text = new TextField();
		text.width = GRAPH_WIDTH;
		text.height = h - GRAPH_HEIGHT - 4 - 5 - 2;
		text.selectable = false;
		text.mouseEnabled = false;
		text.condenseWhite = true;
		text.x = 2;
		text.y = 2;
		addChild(text);
		addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		backgroundRect = new Rectangle(0, 0, 1, GRAPH_HEIGHT);
	}
	
	public override function update(e:Event):Void
	{
		fpsScale = GRAPH_HEIGHT / Lib.current.stage.frameRate;
		timer = Lib.getTimer();
		
		if (timer - 1000 > prevMs)
		{
			prevMs = timer;
			fps = Std.int(frameCount * GRAPH_HEIGHT / Lib.current.stage.frameRate);
			
			graph.lock();
			graph.scroll(1, 0);
			graph.fillRect(backgroundRect, 0xFFFFFF);
			graph.setPixel(0, GRAPH_HEIGHT - fps, 0x00FFFF);
			graph.unlock();
			
			
			text.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#00FFFF'>FPS: " + frameCount + " / " + Lib.current.stage.frameRate + "</FONT>";
			
			frameCount = 0;
		}
		
		frameCount++;
		ms = timer;
	}
	

}