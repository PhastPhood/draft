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
import flash.system.System;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.xml.XML;
import flash.xml.XMLList;


class MemoryMonitor extends StatMonitor
{
	private static inline var GRAPH_WIDTH:Int = 70;
	private static inline var GRAPH_HEIGHT:Int = 40;
	private static inline var MEMORY_SCALE:Float = 1 / 1024 / 1024;
	
	private var fpsScale:Float;
	
	private var timer:Int;
	private var memory:Float;
	private var max:Float;
	
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
		h = 75;
		
	}
	
	public override function init():Void
	{
		max = 0;
		
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
		text.height = 30;
		text.x = 2;
		text.y = 2;
		text.multiline = true;
		addChild(text);
		
		addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		backgroundRect = new Rectangle(0, 0, 1, GRAPH_HEIGHT);
	}
	
	public override function update(e:Event):Void
	{
		timer = Lib.getTimer();
		
		if (timer - 1000 > prevMs)
		{
			prevMs = timer;
			
			memory = System.totalMemory * MEMORY_SCALE;
			max = memory > max ? memory : max;
			
			graph.lock();
			graph.scroll(1, 0);
			graph.fillRect(backgroundRect, 0xFFFFFF);
			graph.setPixel(0, GRAPH_HEIGHT - normalizeMemory(max), 0xDCDCDC);
			graph.setPixel(0, GRAPH_HEIGHT - normalizeMemory(memory), 0x00FFFF);
			graph.unlock();
			
			text.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#00FFFF'>MEM: " + Std.string(memory).substr(0, 5) + "<br></FONT>" + 
			"<FONT FACE = '_sans' SIZE = '9' COLOR = '#DCDCDC'>MAX: " + Std.string(max).substr(0, 5) + "</FONT>";
			
		}
	}
	
	private inline function normalizeMemory(mem:Float):Int
	{
		return Std.int(Math.min(GRAPH_HEIGHT, Math.sqrt(Math.sqrt(mem * 5000))) - 2);
	}
}