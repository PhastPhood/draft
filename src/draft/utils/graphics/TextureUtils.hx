package draft.utils.graphics;
import draft.graphics.Texture2D;
import flash.display.BitmapData;
import flash.display3D.textures.Texture;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author Jeff Gao
 */

class TextureUtils 
{

	public function new() 
	{
		
	}

	public static function nextPowerOfTwo(x:Int):Int
	{
		var v:Int = x;
		v--;
		v |= v >> 1;
		v |= v >> 2;
		v |= v >> 4;
		v |= v >> 8;
		v |= v >> 16;
		v++;
		return v;
	}
	
	public static function makeTextureData(data:BitmapData):Texture2D
	{
		var w:Int = nextPowerOfTwo(data.width);
		var h:Int = nextPowerOfTwo(data.height);
		/*
		var uvpx:Float = 0.5 / w;
		var uvpy:Float = 0.5 / h;
		var uvw:Float = (data.width - 0.5) / w;
		var uvh:Float = (data.height - 0.5) / h;//*/
		var uvpx:Float = 0;
		var uvpy:Float = 0;
		var uvw:Float = (data.width) / w;
		var uvh:Float = (data.height) / h;
		return new Texture2D(data, new Rectangle(uvpx, uvpy, uvw, uvh));
	}
	
	
}