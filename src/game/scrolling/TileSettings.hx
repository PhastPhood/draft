package game.scrolling;
import flash.geom.Rectangle;

/**
 * ...
 * @author asdf
 */

class TileSettings 
{

	public static inline var TILE_BITS:Int = 5;
	public static inline var TILE_SIZE:Int = 1 << TILE_BITS;
	public static var STATIC_TILE_RECT:Rectangle = new Rectangle(0, 0, TILE_SIZE, TILE_SIZE);
	
}