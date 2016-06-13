package editor;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.scene.Scene2D;
import draft.scene.scrolling.TileMap;
import draft.scene.scrolling.TileSettings;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;

/**
 * ...
 * @author asdf
 */

class Minimap extends Sprite, implements IObservable
{

	public var dragSprite:Sprite;
	public var increaseW:Sprite;
	public var increaseH:Sprite;
	public var increaseWH:Sprite;
	
	public var screen:Sprite;
	public var levelEditor:LevelEditor;
	
	public var dragRect:Rectangle;
	
	private inline static var SCREEN_WIDTH:Int = 58;
	private inline static var SCREEN_HEIGHT:Int = 58;
	
	public var observerArray:Array<IObserver>;
	
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
	
	public function new(levelEditor:LevelEditor) 
	{
		
		super();
		this.levelEditor = levelEditor;
		observerArray = new Array<IObserver>();
		
		graphics.lineStyle(1, 0x00FFFF);
		graphics.drawRect(1, 1, SCREEN_WIDTH, SCREEN_HEIGHT);
		graphics.lineStyle(1, 0xDCDCDC);
		graphics.drawRect(0, 0, SCREEN_WIDTH + 2, SCREEN_HEIGHT + 2);
		
		dragRect = new Rectangle();
		increaseH = new Sprite();
		increaseW = new Sprite();
		increaseWH = new Sprite();
		
		screen = new Sprite();
		screen.x = 1;
		screen.y = 1;
		addChild(screen);
		dragSprite = new Sprite();
		addChild(dragSprite);
		dragSprite.x = 1;
		dragSprite.y = 1;
		
		resizeSprites();
		increaseH.graphics.beginFill(0x000000, 0);
		increaseH.graphics.lineStyle(1, 0xDCDCDC);
		increaseH.graphics.drawRect(0, 0, SCREEN_WIDTH + 2, 10);
		increaseH.graphics.endFill();
		increaseH.graphics.moveTo(SCREEN_WIDTH / 2 - 2, 5);
		increaseH.graphics.lineTo(SCREEN_WIDTH / 2 + 4, 5);
		increaseH.graphics.moveTo(SCREEN_WIDTH / 2 + 1, 2);
		increaseH.graphics.lineTo(SCREEN_WIDTH / 2 + 1, 8);
		addChild(increaseH);
		increaseH.x = 0;
		increaseH.y = SCREEN_HEIGHT + 2;
		increaseW.graphics.beginFill(0x000000, 0);
		increaseW.graphics.lineStyle(1, 0xDCDCDC);
		increaseW.graphics.drawRect(0, 0, 10, SCREEN_HEIGHT + 2);
		increaseW.graphics.endFill();
		increaseW.graphics.moveTo(2, SCREEN_HEIGHT / 2 + 1);
		increaseW.graphics.lineTo(8, SCREEN_HEIGHT / 2 + 1);
		increaseW.graphics.moveTo(5, SCREEN_HEIGHT / 2 - 2);
		increaseW.graphics.lineTo(5, SCREEN_HEIGHT / 2 + 4);
		addChild(increaseW);
		increaseW.x = SCREEN_WIDTH + 2;
		increaseW.y = 0;
		increaseWH.graphics.beginFill(0x000000, 0);
		increaseWH.graphics.lineStyle(1, 0xDCDCDC);
		increaseWH.graphics.drawRect(0, 0, 10, 10);
		increaseWH.graphics.endFill();
		addChild(increaseWH);
		increaseWH.x = SCREEN_WIDTH + 2;
		increaseWH.y = SCREEN_HEIGHT + 2;
		
		increaseW.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		increaseH.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		increaseWH.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		
		dragSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		var tilemap:TileMap;
		if (e.target == increaseW)
		{
			for (i in 0...Scene2D.MAX_LAYER_COUNT)
			{
				if (levelEditor.scene.tileLayerArray[i] == null)
					continue;
				tilemap = levelEditor.scene.tileLayerArray[i].tileMap;
				tilemap.resize(tilemap.width + 1, tilemap.height);
			}
			resizeSprites();
		}else if (e.target == increaseH)
		{
			for (i in 0...Scene2D.MAX_LAYER_COUNT)
			{
				if (levelEditor.scene.tileLayerArray[i] == null)
					continue;
				tilemap = levelEditor.scene.tileLayerArray[i].tileMap;
				tilemap.resize(tilemap.width, tilemap.height + 1);
			}
			resizeSprites();
		}else if (e.target == increaseWH)
		{
			for (i in 0...Scene2D.MAX_LAYER_COUNT)
			{
				if (levelEditor.scene.tileLayerArray[i] == null)
					continue;
				tilemap = levelEditor.scene.tileLayerArray[i].tileMap;
				tilemap.resize(tilemap.width + 1, tilemap.height + 1);
			}
			resizeSprites();			
		}else if (e.target == dragSprite)
		{
			dragSprite.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			dragSprite.startDrag(false, dragRect);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
	}
	
	public function onMouseMove(e:MouseEvent):Void
	{
		levelEditor.canvas.offsetX = (dragSprite.x - screen.x) / screen.width * levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width * TileSettings.TILE_SIZE;
		levelEditor.canvas.offsetY = (dragSprite.y - screen.y) / screen.height * levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height * TileSettings.TILE_SIZE;
		levelEditor.canvas.update();
		notify(EditorEvent.MINIMAP_MOVE);
	}
	
	public function onMouseUp(e:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		dragSprite.stopDrag();
		dragSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
	}
	
	public function resizeSprites():Void
	{
		var offsetX:Float = levelEditor.canvas.offsetX;
		var offsetY:Float = levelEditor.canvas.offsetY;
		
		var layerW:Int = levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width;
		var layerH:Int = levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height;
		
		var ratio:Float = layerW/layerH;
		var wClip:Float = SCREEN_WIDTH;
		var hClip:Float = SCREEN_HEIGHT;
		
		if (ratio > 1)
		{
			wClip = SCREEN_WIDTH;
			hClip = wClip / ratio;
		}else
		{
			hClip = SCREEN_HEIGHT;
			wClip = ratio * hClip;
		}
		
		var wRatio = levelEditor.canvas.width / (layerW * TileSettings.TILE_SIZE);
		var hRatio = levelEditor.canvas.height / (layerH * TileSettings.TILE_SIZE);
		wRatio = 20 / layerW;
		hRatio = 15 / layerH;
		
		var dragW:Float = wRatio * wClip;
		var dragH:Float = hRatio * hClip;
		
		screen.x = (SCREEN_WIDTH - wClip) / 2 + 1;
		screen.y = (SCREEN_HEIGHT - hClip) / 2 + 1;
		
		dragSprite.x = offsetX / (layerW * TileSettings.TILE_SIZE) * wClip + screen.x;
		dragSprite.y = offsetY / (layerH * TileSettings.TILE_SIZE) * hClip + screen.y;
		
		screen.graphics.clear();
		dragSprite.graphics.clear();
		
		screen.graphics.lineStyle(2, 0x00DCDCDC);
		screen.graphics.drawRect(0, 0, wClip, hClip);
		dragSprite.graphics.beginFill(0x000000, 0);
		dragSprite.graphics.lineStyle(2, 0x00FFFF);
		dragSprite.graphics.drawRect(0, 0, dragW, dragH);
		dragSprite.graphics.endFill();
		
		dragRect.x = screen.x;
		dragRect.y = screen.y;
		dragRect.width = wClip - dragW;
		dragRect.height = hClip - dragH;
	}
	
	
}