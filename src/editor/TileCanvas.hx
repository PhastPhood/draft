package editor;
import draft.scene.Scene2D;
import draft.scene.scrolling.TileSettings;
import flash.display.Sprite;

/**
 * ...
 * @author asdf
 */

class TileCanvas extends Sprite
{

	public var scene:Scene2D;
	
	public var offsetX:Float;
	public var offsetY:Float;
	
	public var tileID:Int;
	
	public function new(scene:Scene2D) 
	{
		super();
		offsetX = 0;
		offsetY = 0;
		this.scene = scene;
		update();
		
	}
	
	public function update():Void
	{
		graphics.clear();
		graphics.lineStyle(1, 0x00FFFF, 1);
		graphics.beginFill(0xFFFFFF, 0);
		graphics.drawRect(0, 0, scene.width, scene.height);
		graphics.endFill();
		
		graphics.lineStyle(0.8, 0xDCDCDC, 0.5);
		var tileSize:Int = TileSettings.TILE_SIZE;
		
		
		
		var tileOffsetX:Float = offsetX % tileSize;
		var tileOffsetY:Float = offsetY % tileSize;
		
		var linesH:Int = Std.int((scene.width + tileOffsetX) / tileSize) + 1;
		var linesV:Int = Std.int((scene.height + tileOffsetY) / tileSize) + 1;
		
		for (i in 1...linesH)
		{
			graphics.moveTo(i * tileSize - tileOffsetX, 0);
			graphics.lineTo(i * tileSize - tileOffsetX, scene.height);
		}
		for (i in 1...linesV)
		{
			graphics.moveTo(0, i * tileSize - tileOffsetY);
			graphics.lineTo(scene.width, i * tileSize - tileOffsetY);
		}
		
		scene.camera.viewPort.x = offsetX;
		scene.camera.viewPort.y = offsetY;
		
		scene.render();
	}
	
	
	
}