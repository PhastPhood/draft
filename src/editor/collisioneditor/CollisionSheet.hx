package editor.collisioneditor;
import draft.math.Vector2D;
import draft.scene.scrolling.TileSettings;
import draft.scene.scrolling.TileSheet;
import flash.display.BitmapData;

/**
 * ...
 * @author asdf
 */

class CollisionSheet
{
	public var points:Array<Array<Vector2D>>;
	
	
	public function new(map:BitmapData, tilesheet:TileSheet) 
	{
		points = new Array<Array<Vector2D>>();
		
		var tileX:Int;
		var tileY:Int;
		
		var posX:Int;
		var posY:Int;
		
		var centerX:Int;
		var centerY:Int;
		
		var uvX:Float;
		var uvY:Float;
		
		var tileSheetId:Int;
		
		for (i in 0...map.width)
		{
			for (j in 0...map.height)
			{
				if (map.getPixel(i, j) == 0x000000)
				{
					tileX = Std.int(i / TileSettings.TILE_SIZE);
					tileY = Std.int(j / TileSettings.TILE_SIZE);
					
					centerX = tileX * TileSettings.TILE_SIZE + Std.int(TileSettings.TILE_SIZE / 2);
					centerY = tileY * TileSettings.TILE_SIZE + Std.int(TileSettings.TILE_SIZE / 2);
					
					uvX = centerX / tilesheet.batchTexture.width;
					uvY = centerY / tilesheet.batchTexture.height;
					
					tileSheetId = 0;
					for (k in 0...tilesheet.uvRectangleArray.length)
					{
						if (uvX > tilesheet.uvRectangleArray[k].x && uvY > tilesheet.uvRectangleArray[k].y)
						{
							if (uvX < tilesheet.uvRectangleArray[k].right && uvY < tilesheet.uvRectangleArray[k].bottom)
							{
								tileSheetId = k;
							}
						}
					}
					
					if (points[tileSheetId] == null)
						points[tileSheetId] = new Array<Vector2D>();
					
					posX = i % TileSettings.TILE_SIZE;
					posY = j % TileSettings.TILE_SIZE;
					
					points[tileSheetId].push(new Vector2D(posX, posY));
				}
			}
		}
	}
	
}