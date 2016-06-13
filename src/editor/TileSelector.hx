package editor;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.scene.scrolling.TileSettings;
import draft.scene.scrolling.TileSheet;
import draft.scene.ui.ComponentSkin;
import draft.scene.ui.scrollbar.ScrollBar;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.ui.Mouse;

/**
 * ...
 * @author asdf
 */

class TileSelector extends Sprite, implements IObservable
{

	public var tileSheet:TileSheet;
	public var scrollH:ScrollBar;
	public var scrollV:ScrollBar;
	public var tileScreen:Bitmap;
	public var tileScreenSprite:Sprite;
	public var displayRect:Rectangle;
	
	public var selectedTileArray:Array<Array<Int>>;
	public var selectionRectangle:Sprite;
	public var dragRectangle:Sprite;
	
	public var startX:Float;
	public var startY:Float;
	
	public var selectedTilesW:Int;
	public var selectedTilesH:Int;
	
	public var observerArray:Array<IObserver>;
	
	public function new(w:Int, h:Int, scrollBarSkin:ComponentSkin) 
	{
		super();
		var sbW:Int = Std.int(scrollBarSkin.boundaryArray[0].height);
		var w1:Int = w - sbW;
		var w2:Int = h - sbW;
		
		observerArray = new Array<IObserver>();
		
		scrollH = new ScrollBar(scrollBarSkin, w1, w1 - Std.int(scrollBarSkin.boundaryArray[0].width + scrollBarSkin.boundaryArray[4].width), 0, 0, 0);
		scrollV = new ScrollBar(scrollBarSkin, w2, w2 - Std.int(scrollBarSkin.boundaryArray[0].width + scrollBarSkin.boundaryArray[4].width), 0, 0, 0);
		
		scrollH.y = w2;
		scrollV.rotation = 90;
		scrollV.x = w;
		addChild(scrollH);
		addChild(scrollV);
		
		scrollH.bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarHDown, false, 0, true);
		scrollV.bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarVDown, false, 0, true);
		
		tileScreen = new Bitmap(new BitmapData(w1, w2, true));
		tileScreenSprite = new Sprite();
		tileScreenSprite.addChild(tileScreen);
		addChild(tileScreenSprite);
		displayRect = new Rectangle(0, 0, w1, w2);
		
		selectionRectangle = new Sprite();
		addChild(selectionRectangle);
		
		var border:Sprite = new Sprite();
		border.graphics.lineStyle(1, 0x00FFFF);
		border.graphics.drawRect(0, 0, w, h);
		addChild(border);
		
		selectedTilesW = 1;
		selectedTilesH = 1;
		
		dragRectangle = new Sprite();
		addChild(dragRectangle);
		
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
		selectedTileArray = new Array<Array<Int>>();
		selectedTileArray[0] = new Array<Int>();
	}
	
	public function onMouseWheel(e:MouseEvent):Void
	{
		scrollV.bar.x -= e.delta;
		
		if (scrollV.bar.x > scrollV.boundsRect.right)
		{
			scrollV.bar.x = scrollV.boundsRect.right;
		}
		if (scrollV.bar.x < scrollV.boundsRect.left)
			scrollV.bar.x = scrollV.boundsRect.left;
		refreshTileScreen();
		drawSelectionRectangle();
	}
	
	public function setTileSheet(sheet:TileSheet):Void
	{
		tileScreen.removeEventListener(MouseEvent.MOUSE_DOWN, tilesOnMouseDown);
		
		tileSheet = sheet;
		var w:Int = Std.int(sheet.batchTexture.image.width - (width - scrollH.height));
		var h:Int = Std.int(sheet.batchTexture.image.height - (height - scrollH.height));
		
		if (w > 0)
		{
			scrollH.setBarWidth(Std.int(tileScreen.width / sheet.batchTexture.image.width * scrollH.background.width));
			scrollH.maxValue = w;
			scrollH.setValue(0);
		}
		if (h > 0)
		{
			scrollV.setBarWidth(Std.int(tileScreen.height / sheet.batchTexture.image.height * scrollV.background.width));
			scrollV.maxValue = h;
			scrollV.setValue(0);
		}
		
		refreshTileScreen();
		
		tileScreenSprite.addEventListener(MouseEvent.MOUSE_DOWN, tilesOnMouseDown, false, 0, true);
	}
	
	public function tilesOnMouseDown(e:MouseEvent):Void
	{
		var scrollX:Float = scrollH.getValue();
		var scrollY:Float = scrollV.getValue();
		
		var clickX:Float = e.localX + scrollX;
		var clickY:Float = e.localY + scrollY;
		
		var uvX:Float = clickX / tileSheet.batchTexture.width;
		var uvY:Float = clickY / tileSheet.batchTexture.height;
		
		var rect:Rectangle = tileSheet.uvRectangleArray[0];
		var n:Int = tileSheet.uvRectangleArray.length;
		for (i in 0...n)
		{
			rect = tileSheet.uvRectangleArray[i];
			if (uvX > rect.x && uvY > rect.y)
			{
				//trace(uvX + ", " + uvY + ", " + rect.toString() + ", " + i);
				if (uvX < rect.right && uvY < rect.bottom)
				{
					selectedTileArray[0][0] = i;
					break;
				}
			}
		}
		startX = e.localX + scrollX;
		startY = e.localY + scrollY;
		
		selectedTilesW = 1;
		selectedTilesH = 1;
		
		notify(EditorEvent.TILE_CHANGE);
		
		drawSelectionRectangle();
		
		
		tileScreenSprite.removeEventListener(MouseEvent.MOUSE_DOWN, tilesOnMouseDown);
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
	}
	
	public function onMouseMove(e:MouseEvent):Void
	{
		dragRectangle.graphics.clear();
		dragRectangle.graphics.lineStyle(1, 0xDCDCDC);
		var scrollX:Float = scrollH.getValue();
		var scrollY:Float = scrollV.getValue();
		dragRectangle.graphics.drawRect(startX - scrollX, startY - scrollY, e.localX + scrollX - startX, e.localY + scrollY - startY);
		var endXTile:Int = Std.int((e.localX + scrollH.getValue()) / TileSettings.TILE_SIZE);
		var endYTile:Int = Std.int((e.localY + scrollV.getValue()) / TileSettings.TILE_SIZE);
		var halfWidth:Int = Std.int(TileSettings.TILE_SIZE / 2);
		var startXTile:Int = Std.int(startX / TileSettings.TILE_SIZE);
		var startYTile:Int = Std.int(startY / TileSettings.TILE_SIZE);
		
		var switchVar:Int;
		if (startXTile > endXTile)
		{
			switchVar = endXTile;
			endXTile = startXTile;
			startXTile = switchVar;
		}
		if (startYTile > endYTile)
		{
			switchVar = endYTile;
			endYTile = startYTile;
			startYTile = switchVar;
		}
		selectedTilesW = endXTile - startXTile + 1;
		selectedTilesH = endYTile - startYTile + 1;
		
		var n:Int = tileSheet.uvRectangleArray.length;
		var uvX:Float;
		var uvY:Float;
		var rect:Rectangle;
		for (i in 0...selectedTilesH)
		{
			if (selectedTileArray[i] == null)
				selectedTileArray[i] = new Array<Int>();
			for (j in 0...selectedTilesW)
			{
				uvX = ((startXTile + j) * TileSettings.TILE_SIZE + halfWidth) / tileSheet.batchTexture.width;
				uvY = ((startYTile + i) * TileSettings.TILE_SIZE + halfWidth) / tileSheet.batchTexture.height;
				//trace(uvX + ", " + uvY);
				for (k in 0...n)
				{
					rect = tileSheet.uvRectangleArray[k];
					if (uvX > rect.x && uvY > rect.y)
					{
						//trace(uvX + ", " + uvY + ", " + rect.toString() + ", " + i);
						if (uvX < rect.right && uvY < rect.bottom)
						{
							selectedTileArray[i][j] = k;
							//trace(k);
							break;
						}
					}
				}
			}
		}
		
		drawSelectionRectangle();
	}
	
	public function onMouseUp(e:MouseEvent):Void
	{
		removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		dragRectangle.graphics.clear();
		tileScreenSprite.addEventListener(MouseEvent.MOUSE_DOWN, tilesOnMouseDown, false, 0, true);
	}
	
	public function drawSelectionRectangle():Void
	{
		selectionRectangle.graphics.clear();
		selectionRectangle.graphics.lineStyle(3, 0x00FFFF, 1);
		
		var scrollX:Float = scrollH.getValue();
		var scrollY:Float = scrollV.getValue();
		
		var uvTop:Float = Math.POSITIVE_INFINITY;
		var uvBot:Float = Math.NEGATIVE_INFINITY;
		var uvRight:Float = Math.NEGATIVE_INFINITY;
		var uvLeft:Float = Math.POSITIVE_INFINITY;
		
		var t:Int;
		
		for (i in 0...selectedTilesH)
		{
			for (j in 0...selectedTilesW)
			{
				t = selectedTileArray[i][j];
				if (tileSheet.uvRectangleArray[t].x < uvLeft)
					uvLeft = tileSheet.uvRectangleArray[t].x;
				if (tileSheet.uvRectangleArray[t].right > uvRight)
					uvRight = tileSheet.uvRectangleArray[t].right;
				if (tileSheet.uvRectangleArray[t].y < uvTop)
					uvTop = tileSheet.uvRectangleArray[t].y;
				if (tileSheet.uvRectangleArray[t].bottom > uvBot)
					uvBot = tileSheet.uvRectangleArray[t].bottom;
			}
		}
		var rect:Rectangle = new Rectangle(uvLeft, uvTop, uvRight - uvLeft, uvBot - uvTop);
		//trace(selectedTilesW + ", " + selectedTilesH);
		//trace(rect);
		
		var top:Float = rect.y * tileSheet.batchTexture.height - scrollY;
		var bottom:Float = rect.bottom * tileSheet.batchTexture.height - scrollY;
		var left:Float = rect.x * tileSheet.batchTexture.width - scrollX;
		var right:Float = rect.right * tileSheet.batchTexture.width - scrollX;
		
		if (left > tileScreenSprite.width || right < 0 || bottom < 0 || top > tileScreenSprite.height)
			return;
		
		var topClip:Float = top < 0 ? 0 : top;
		var bottomClip:Float = bottom > tileScreenSprite.height ? tileScreenSprite.height : bottom;
		var leftClip:Float = left < 0 ? 0 : left;
		var rightClip:Float = right > tileScreenSprite.width ? tileScreenSprite.width : right;
		
		if (topClip == top)
		{
			selectionRectangle.graphics.moveTo(leftClip, topClip);
			selectionRectangle.graphics.lineTo(rightClip, topClip);
		}
		if (bottomClip == bottom)
		{
			selectionRectangle.graphics.moveTo(leftClip, bottomClip);
			selectionRectangle.graphics.lineTo(rightClip, bottomClip);
		}
		if (rightClip == right)
		{
			selectionRectangle.graphics.moveTo(rightClip, topClip);
			selectionRectangle.graphics.lineTo(rightClip, bottomClip);
		}
		if (leftClip == left)
		{
			selectionRectangle.graphics.moveTo(leftClip, topClip);
			selectionRectangle.graphics.lineTo(leftClip, bottomClip);
		}
		
		notify(EditorEvent.TILE_CHANGE);
	}
	
	public function refreshTileScreen():Void
	{
		if (tileSheet == null)
			return;
		tileScreen.bitmapData.fillRect(tileScreen.bitmapData.rect, 0x00000000);
		displayRect.x = scrollH.getValue();
		displayRect.y = scrollV.getValue();
		tileScreen.bitmapData.copyPixels(tileSheet.batchTexture.image, displayRect, new Point(), null, null, true);
	}
	
	public function onBarHDown(e:MouseEvent):Void
	{
		scrollH.bar.removeEventListener(MouseEvent.MOUSE_DOWN, onBarHDown);
		scrollH.bar.startDrag(false, scrollH.boundsRect);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onBarHMove, false, 0, true);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onBarHUp, false, 0, true);
	}
	
	public function onBarHMove(e:MouseEvent):Void
	{
		refreshTileScreen();
		drawSelectionRectangle();
	}
	
	public function onBarHUp(e:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onBarHUp);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onBarHMove);
		scrollH.bar.stopDrag();
		scrollH.bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarHDown, false, 0, true);
	}
	
	public function onBarVDown(e:MouseEvent):Void
	{
		scrollV.bar.removeEventListener(MouseEvent.MOUSE_DOWN, onBarVDown);
		scrollV.bar.startDrag(false, scrollV.boundsRect);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onBarVMove, false, 0, true);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onBarVUp, false, 0, true);
	}
	
	public function onBarVMove(e:MouseEvent):Void
	{
		refreshTileScreen();
		drawSelectionRectangle();
	}
	
	public function onBarVUp(e:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onBarVUp);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onBarVMove);
		scrollV.bar.stopDrag();
		scrollV.bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarVDown, false, 0, true);
	}
	
	
	public function attach(o:IObserver):Void
	{
		observerArray.push(o);
	}
	
	public function detach(o:IObserver):Void
	{
		observerArray.remove(o);
	}
	
	public function notify(type:Int, data:Dynamic = null):Void
	{
		for (o in observerArray)
		{
			o.update(type, this, data);
		}
	}
}