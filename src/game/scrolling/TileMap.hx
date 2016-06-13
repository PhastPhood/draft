package game.scrolling;

/**
 * ...
 * @author 
 */

class TileMap 
{

	public var data:Array<Array<Int>>;
	public var width:Int;
	public var height:Int;
	public var tileSheet:TileSheet;
	
	//[y][x]
	public function new(w:Int, h:Int, sheet:TileSheet) 
	{
		width = w;
		height = h;
		tileSheet = sheet;
		data = new Array<Array<Int>>();
		
		for (i in 0...h)
		{
			data[i] = new Array<Int>();
			for (j in 0...w)
			{
				data[i][j] = 0;// Std.int(Math.random() * 2) * 2;
			}
		}
	}
	
	public function resize(w:Int, h:Int):Void
	{
		if (h > height)
		{
			for (i in height...h)
			{
				data[i] = new Array<Int>();
			}
		}
		if (w > width)
		{
			for (i in 0...h)
			{
				for (j in width...w)
				{
					data[i][j] = 0;
				}
			}
		}
		width = w;
		height = h;
	}
	
}