package editor.state;
import draft.scene.scrolling.TileSettings;
import flash.events.MouseEvent;
import flash.Lib;

/**
 * ...
 * @author asdf
 */

class EraseState extends PlaceState
{

	public function new(e:editor.LevelEditor) 
	{
		super(e);
	}
	
	override public function stateOn():Void
	{
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown, false, 0, true);
	}
	
	override public function stateOff():Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, canvasMouseUp);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, canvasMouseMove);
	}
	
	override public function placeTile(x:Float, y:Float):Void
	{
		var placeX:Float = x + levelEditor.canvas.offsetX;
		var placeY:Float = y + levelEditor.canvas.offsetY;
		
		var tileX:Int = Std.int(placeX / TileSettings.TILE_SIZE);
		var tileY:Int = Std.int(placeY / TileSettings.TILE_SIZE);
		
		if (levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.data[tileY] == null)
			return;
		levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.data[tileY][tileX] = 0;
		//trace(editor.tileMapArray[editor.currentLayer].data[tileY][tileX]);
		levelEditor.scene.render();
	}
	
	
	
}