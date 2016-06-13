package draft.scene.ui.scrollbar;
import draft.scene.ui.ComponentSkin;
import draft.scene.ui.UIComponent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author asdf
 */

class ScrollBar extends UIComponent
{
	public var barWidth:Int;
	public var backWidth:Int;
	public var minValue:Float;
	public var maxValue:Float;
	
	public var minButton:Sprite;
	public var maxButton:Sprite;
	public var background:Sprite;
	public var bar:Sprite;
	public var barBitmap:Bitmap;
	
	public var boundsRect:Rectangle;
	
	public function new(skin:ComponentSkin, w:Int, barWidth:Int, minValue:Float, maxValue:Float, defaultValue:Float) 
	{
		this.skin = skin;
		
		this.minValue = minValue;
		this.maxValue = maxValue;
		
		var bd1:BitmapData = new BitmapData(Std.int(skin.boundaryArray[0].width), Std.int(skin.boundaryArray[0].height), true);
		var p:Point = new Point();
		
		bd1.copyPixels(skin.texture, skin.boundaryArray[0], p, null, null, true);
		var bitmap1:Bitmap = new Bitmap(bd1);
		minButton = new Sprite();
		minButton.addChild(bitmap1);
		var bd2:BitmapData = new BitmapData(Std.int(skin.boundaryArray[4].width), Std.int(skin.boundaryArray[4].height), true);
		bd2.copyPixels(skin.texture, skin.boundaryArray[4], p, null, null, true);
		var bitmap2:Bitmap = new Bitmap(bd2);
		maxButton = new Sprite();
		maxButton.addChild(bitmap2);
		maxButton.x = w - skin.boundaryArray[4].width;
		var range:Float = maxValue - minValue;
		
		
		backWidth = w - Std.int(skin.boundaryArray[0].width + skin.boundaryArray[4].width);
		boundsRect = new Rectangle(minButton.width, 0, 0, 0);
		barBitmap = new Bitmap();
		bar = new Sprite();
		bar.addChild(barBitmap);
		setBarWidth(barWidth);
		var repeatWidth:Int = Std.int(skin.boundaryArray[5].width);
		
		var n:Int = Std.int(backWidth / repeatWidth);
		p.x = 0;
		var backgroundData:BitmapData = new BitmapData(backWidth, Std.int(skin.boundaryArray[5].height));
		
		for ( i in 0...n)
		{
			backgroundData.copyPixels(skin.texture, skin.boundaryArray[5], p, null, null, true);
			p.x += repeatWidth;
		}
		var rect:Rectangle = new Rectangle(skin.boundaryArray[5].x, skin.boundaryArray[5].y, backWidth - n * repeatWidth, skin.boundaryArray[5].height);
		backgroundData.copyPixels(skin.texture, rect, p, null, null, true);
		background = new Sprite();
		background.addChild(new Bitmap(backgroundData));
		background.x = skin.boundaryArray[0].width;
		
		addChild(background);
		addChild(minButton);
		addChild(maxButton);
		setValue(defaultValue);
		addChild(bar);
		
		super();
	}
	
	public function setBarWidth(w:Int):Void
	{
		barWidth = w;
		
		var p:Point = new Point();
		barBitmap.bitmapData = new BitmapData(w, Std.int(skin.boundaryArray[2].height));
		
		barBitmap.bitmapData.copyPixels(skin.texture, skin.boundaryArray[1], p, null, null, true);
		var endWidth:Float = skin.boundaryArray[1].width;
		
		var midWidth:Int = w - Std.int(2 * endWidth);
		
		var repeatWidth:Int = Std.int(skin.boundaryArray[2].width);
		var n:Int = Std.int(midWidth / repeatWidth);
		p.x = endWidth;
		for ( i in 0...n)
		{
			barBitmap.bitmapData.copyPixels(skin.texture, skin.boundaryArray[2], p, null, null, true);
			p.x += repeatWidth;
		}
		var rect:Rectangle = new Rectangle(skin.boundaryArray[2].x, skin.boundaryArray[2].y, midWidth - n * repeatWidth, skin.boundaryArray[2].height);
		barBitmap.bitmapData.copyPixels(skin.texture, rect, p, null, null, true);
		p.x = w - endWidth;
		barBitmap.bitmapData.copyPixels(skin.texture, skin.boundaryArray[3], p, null, null, true);
		
		boundsRect.width = backWidth - barWidth;
	}
	
	public function getValue():Float
	{
		if (minValue == maxValue)
			return minValue;
		return (bar.x - minButton.width) / (backWidth - barWidth) * (maxValue - minValue) + minValue;
	}
	
	public function setValue(val:Float):Void
	{
		if (minValue != maxValue)
			bar.x = (val - minValue) / (maxValue - minValue) * (backWidth - barWidth) + minButton.width;
		else
			bar.x = 0.5 * backWidth + minButton.width - barWidth / 2;
	}
	
}