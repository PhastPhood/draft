package editor.state;
import draft.math.Vector2D;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.scene.scrolling.TileSettings;
import editor.EditorEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;

/**
 * ...
 * @author asdf
 */

class PlaceState extends EditorState, implements IObserver
{

	public var placeXTile:Int;
	public var placeYTile:Int;
	public var collisionOverlay:Sprite;
	public var tileGhost:Bitmap;
	
	public function new(e:editor.LevelEditor) 
	{
		super(e);
		placeXTile = 0;
		placeYTile = 0;
		collisionOverlay = new Sprite();
		tileGhost = new Bitmap(new BitmapData(640, 480, true, 0x00000000));
		tileGhost.alpha = 0.5;
	}
	
	override public function stateOn():Void
	{
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown, false, 0, true);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver, false, 0, true);
		levelEditor.addChild(levelEditor.selector);
		levelEditor.selector.attach(this);
	}
	
	override public function stateOff():Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, canvasMouseUp);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, canvasMouseMove);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver);
		levelEditor.removeChild(levelEditor.selector);
		levelEditor.selector.detach(this);
	}
	
	public function placeTile(x:Float, y:Float):Void
	{
		var placeX:Float = x + levelEditor.canvas.offsetX;
		var placeY:Float = y + levelEditor.canvas.offsetY;
		
		var tileX:Int = Std.int(placeX / TileSettings.TILE_SIZE);
		var tileY:Int = Std.int(placeY / TileSettings.TILE_SIZE);
		
		for (i in 0...levelEditor.selector.selectedTilesH)
		{
			if (placeYTile + i < 0)
				continue;
			if (placeYTile + i >= levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height)
				continue;	
			for (j in 0...levelEditor.selector.selectedTilesW)
			{
				if (placeXTile + j < 0)
					continue;
				if (placeXTile + j >= levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width)
					continue;
				
				levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.data[placeYTile + i][placeXTile + j] = levelEditor.selector.selectedTileArray[i][j];
			}
		}
		//trace(editor.tileMapArray[editor.currentLayer].data[tileY][tileX]);
		levelEditor.scene.render();
	}
	
	public function canvasMouseDown(e:MouseEvent):Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown);
		placeTile(e.localX, e.localY);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_MOVE, canvasMouseMove, false, 0, true);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, canvasMouseUp, false, 0, true);
	}
	
	public function canvasMouseMove(e:MouseEvent):Void
	{
		placeTile(e.localX, e.localY);
		
	}
	
	public function canvasMouseUp(e:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, canvasMouseUp);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, canvasMouseMove);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown, false, 0, true);
	}
	
	public function canvasMouseOver(e:MouseEvent):Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut, false, 0, true);
		levelEditor.addChild(tileGhost);
		levelEditor.addChild(collisionOverlay);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_MOVE, ghostMouseMove, false, 0, true);
	}
	
	public function ghostMouseMove(e:MouseEvent):Void
	{
		var tileW:Int = levelEditor.selector.selectedTilesW;
		var tileH:Int = levelEditor.selector.selectedTilesH;
		if (tileW % 2 == 1)
		{
			placeXTile = Std.int((e.localX + levelEditor.canvas.offsetX) / TileSettings.TILE_SIZE) - Std.int(tileW/2);
		}else
		{
			placeXTile = Math.round((e.localX + levelEditor.canvas.offsetX) / TileSettings.TILE_SIZE) - Std.int(tileW/2);
		}
		if (tileH % 2 == 1)
		{
			placeYTile = Std.int((e.localY + levelEditor.canvas.offsetY) / TileSettings.TILE_SIZE) - Std.int(tileH/2);
		}else
		{
			placeYTile = Math.round((e.localY + levelEditor.canvas.offsetY) / TileSettings.TILE_SIZE) - Std.int(tileH/2);
		}
		tileGhost.x = placeXTile * TileSettings.TILE_SIZE - levelEditor.canvas.offsetX;
		tileGhost.y = placeYTile * TileSettings.TILE_SIZE - levelEditor.canvas.offsetY;
		collisionOverlay.x = placeXTile * TileSettings.TILE_SIZE - levelEditor.canvas.offsetX;
		collisionOverlay.y = placeYTile * TileSettings.TILE_SIZE - levelEditor.canvas.offsetY;
	}
	
	public function changeTileGhost():Void
	{
		tileGhost.bitmapData.fillRect(tileGhost.bitmapData.rect, 0x00000000);
		var uvRect:Rectangle;
		var w:Int = levelEditor.tileSheets[0].batchTexture.width;
		var h:Int = levelEditor.tileSheets[0].batchTexture.height;
		var pixelRect:Rectangle = new Rectangle();
		//var rect:Rectangle = new Rectangle();
		var point:Point = new Point();
		var tileNumber:Int;
		var pointArray:Array<Vector2D>;
		var np:Vector2D = new Vector2D();
		collisionOverlay.graphics.clear();
		collisionOverlay.graphics.lineStyle(1, 0x00FFFF);
		for (i in 0...levelEditor.selector.selectedTilesH)
		{
			for (j in 0...levelEditor.selector.selectedTilesW)
			{
				tileNumber = levelEditor.selector.selectedTileArray[i][j];
				uvRect = levelEditor.tileSheets[0].uvRectangleArray[tileNumber];
				point.x = j * TileSettings.TILE_SIZE;
				point.y = i * TileSettings.TILE_SIZE;
				pixelRect.x = uvRect.x * w;
				pixelRect.y = uvRect.y * h;
				pixelRect.width = uvRect.width * w;
				pixelRect.height = uvRect.height * h;
				tileGhost.bitmapData.copyPixels(levelEditor.tileSheets[0].batchTexture.image, pixelRect, point, null, null, true);
				pointArray = levelEditor.collisionSheets[0].points[tileNumber];
				if (pointArray == null)
					continue;
				for (p in pointArray)
				{
					np.x = point.x + p.x;
					np.y = point.y + p.y;
					collisionOverlay.graphics.moveTo(np.x - 2, np.y - 2);
					collisionOverlay.graphics.lineTo(np.x + 2, np.y + 2);
					collisionOverlay.graphics.moveTo(np.x - 2, np.y + 2);
					collisionOverlay.graphics.lineTo(np.x + 2, np.y - 2);
				}
				
			}
		}
		
	}
	
	public function canvasMouseOut(e:MouseEvent):Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, ghostMouseMove);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OVER, canvasMouseOver, false, 0, true);
		levelEditor.removeChild(tileGhost);
		levelEditor.removeChild(collisionOverlay);
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		switch(type)
		{
			case EditorEvent.TILE_CHANGE:
				changeTileGhost();
		}
	}
	
}