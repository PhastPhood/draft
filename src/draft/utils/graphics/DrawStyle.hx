/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils.graphics;

class DrawStyle
{

	public var drawLines:Bool;
	public var lineColor:UInt;
	public var lineThickness:Float;
	public var lineAlpha:Float;
	
	public var drawFill:Bool;
	public var fillAlpha:Float;
	public var fillColor:UInt;
	public function new() 
	{
		drawLines = true;
		drawFill = true;
		
		lineColor = 0x000000;
		lineThickness = 1;
		lineAlpha = 1;
		
		fillColor = 0xFFFFFF;
		fillAlpha = 1;
	}
	
}