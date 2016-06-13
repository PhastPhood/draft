/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils.graphics;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import flash.display.Graphics;

class DrawUtils 
{
	
	public static inline function drawLine(canvas:Graphics, style:DrawStyle, p1:Vector2D, p2:Vector2D):Void
	{
		canvas.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
		canvas.moveTo(p1.x, p1.y);
		canvas.lineTo(p2.x, p2.y);
	}
	
	public static inline function drawPoint(canvas:Graphics, style:DrawStyle, position:Vector2D):Void
	{
		canvas.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
		
		canvas.moveTo(position.x - 2, position.y - 2);
		canvas.lineTo(position.x + 2, position.y + 2);
		canvas.moveTo(position.x - 2, position.y + 2);
		canvas.lineTo(position.x + 2, position.y - 2);
	}
	
	public static inline function drawCircle(canvas:Graphics, style:DrawStyle, position:Vector2D, radius:Float):Void
	{
		canvas.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
		canvas.beginFill(style.fillColor, style.fillAlpha);
		
		canvas.drawCircle(position.x, position.y, radius);
		canvas.endFill();
		
	}
	
	public static inline function drawAABB(canvas:Graphics, style:DrawStyle, position:Vector2D, width:Float, height:Float):Void
	{
		canvas.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
		canvas.beginFill(style.fillColor, style.fillAlpha);
		
		canvas.drawRect(position.x, position.y, width, height);
		canvas.endFill();
	}
	
	public static inline function drawRectangle(canvas:Graphics, style:DrawStyle, position:Vector2D, halfWidthVector:Vector2D, halfHeightVector:Vector2D):Void
	{
		canvas.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
		canvas.beginFill(style.fillColor, style.fillAlpha);
		
		var wx:Float = halfWidthVector.x;
		var wy:Float = halfWidthVector.y;
		var hx:Float = halfHeightVector.x;
		var hy:Float = halfHeightVector.y;
		canvas.moveTo(position.x + wx + hx, position.y + wy + hy);
		canvas.lineTo(position.x - wx + hx, position.y - wy + hy);
		canvas.lineTo(position.x - wx - hx, position.y - wy - hy);
		canvas.lineTo(position.x + wx - hx, position.y + wy - hy);
		canvas.lineTo(position.x + wx + hx, position.y + wy + hy);
				
		drawLine(canvas, style, position, new Vector2D(position.x + wx, position.y + wy));
		drawLine(canvas, style, position, new Vector2D(position.x + hx, position.y + hy));

		canvas.endFill();
	}
	
	public static inline function drawPolygon(canvas:Graphics, style:DrawStyle, vertices:Array<Vector2D>, position:Vector2D, orientation:RotationMatrix2D):Void
	{
		canvas.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha);
		canvas.beginFill(style.fillColor, style.fillAlpha);
		
		var a:Vector2D = vertices[vertices.length - 1];
		var px:Float = a.x * orientation.i1j1 + a.y * orientation.i1j2 + position.x;
		var py:Float = a.x * orientation.i2j1 + a.y * orientation.i2j2 + position.y;
		canvas.moveTo(px, py);
		
		for (a in vertices) {
			px = a.x * orientation.i1j1 + a.y * orientation.i1j2 + position.x;
			py = a.x * orientation.i2j1 + a.y * orientation.i2j2 + position.y;
			canvas.lineTo(px, py);
		}
		canvas.endFill();

	}
}