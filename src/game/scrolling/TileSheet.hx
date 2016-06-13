package game.scrolling;
import draft.graphics.BatchTexture;
import draft.utils.graphics.TextureUtils;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.geom.Rectangle;

/**
 * ...
 * @author asdf
 */

class TileSheet 
{

	public var batchTexture:BatchTexture;
	public var uvRectangleArray:Array<Rectangle>;
	
	//tileCoordinates: [x, y, w, h]
	public function new(tiles:BitmapData, tileCoordinates:Array<Array<Int>>) 
	{
		batchTexture = new BatchTexture(tiles);
		uvRectangleArray = new Array<Rectangle>();
		var rect:Rectangle;
		var x1:Float;
		var x2:Float;
		var y1:Float;
		var y2:Float;
		uvRectangleArray.push(new Rectangle());
		for (ar in tileCoordinates)
		{
			x1 = ar[0];
			x2 = ar[2];
			y1 = ar[1];
			y2 = ar[3];
			rect = new Rectangle(x1, y1, x2, y2);
			uvRectangleArray.push(rect);
		}
	}
	
	public function init(context:Context3D):Void
	{
		if (batchTexture.texture != null)
			return;
		batchTexture.init(context);
		for (rect in uvRectangleArray)
		{
			rect.x /= batchTexture.width;
			rect.width /= batchTexture.width;
			rect.y /= batchTexture.height;
			rect.height /= batchTexture.height;
		}
	}
	
}