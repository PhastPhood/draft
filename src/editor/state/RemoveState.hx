package editor.state;
import draft.math.AABB2D;
import draft.math.Vector2D;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import editor.EditorEvent;
import editor.LevelEditor;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * ...
 * @author asdf
 */

class RemoveState extends EditorState, implements IObserver
{

	public var polygonSpriteArray:Array<Sprite>;
	public var AABBArray:Array<AABB2D>;
	public var canvasSprite:Sprite;
	
	public function new(e:LevelEditor) 
	{
		super(e);
		polygonSpriteArray = new Array<Sprite>();
		AABBArray = new Array<AABB2D>();
		canvasSprite = new Sprite();
	}
	
	override public function stateOn():Void
	{
		//levelEditor.canvas.addEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown, false, 0, true);
		calculateAABBs();
		drawPolygons();
		levelEditor.addChild(canvasSprite);
		levelEditor.minimap.attach(this);
		canvasSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
	}
	
	override public function stateOff():Void
	{
		//levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_DOWN, canvasMouseDown);
		//Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, canvasMouseUp);
		//levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, canvasMouseMove);
		clearAndRemove();
		levelEditor.removeChild(canvasSprite);
		levelEditor.minimap.detach(this);
	}
	
	public function onMouseOver(e:MouseEvent):Void
	{
		var s:Sprite = polygonSpriteArray[0];
		for (i in 0...polygonSpriteArray.length)
		{
			s = polygonSpriteArray[i];
			if (e.target != s)
				continue;
			s.graphics.clear();
			if (levelEditor.polygonDataArray[i][0] == 0)
				s.graphics.lineStyle(4, 0x00FFFF);
			else if (levelEditor.polygonDataArray[i][0] == 1)
				s.graphics.lineStyle(4, 0xFF0000);
			drawPolygon(s.graphics, levelEditor.polygonPointArray[i]);
			break;
		}
		canvasSprite.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		s.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
		s.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		var s:Sprite = polygonSpriteArray[0];
		for (i in 0...polygonSpriteArray.length)
		{
			s = polygonSpriteArray[i];
			if (e.target != s)
				continue;
			s.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			s.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			canvasSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			s.graphics.clear();
			canvasSprite.removeChild(s);
			AABBArray.remove(AABBArray[i]);
			polygonSpriteArray.remove(polygonSpriteArray[i]);
			levelEditor.polygonPointArray.remove(levelEditor.polygonPointArray[i]);
			levelEditor.polygonDataArray.remove(levelEditor.polygonDataArray[i]);
			drawPolygons();
			break;
		}		
	}
	
	public function onMouseOut(e:MouseEvent):Void
	{
		var s:Sprite = polygonSpriteArray[0];
		
		for (i in 0...polygonSpriteArray.length)
		{
			s = polygonSpriteArray[i];
			if (e.target != s)
				continue;
			s.graphics.clear();
			if (levelEditor.polygonDataArray[i][0] == 0)
				s.graphics.lineStyle(2, 0x00FFFF);
			else if (levelEditor.polygonDataArray[i][0] == 1)
				s.graphics.lineStyle(2, 0xFF0000);
			drawPolygon(s.graphics, levelEditor.polygonPointArray[i]);
			break;
		}
		
		s.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		canvasSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
	}
	
	public function calculateAABBs():Void
	{
		var px:Float;
		var py:Float;
		var minx:Float = Math.POSITIVE_INFINITY;
		var miny:Float = Math.POSITIVE_INFINITY;
		var maxx:Float = Math.NEGATIVE_INFINITY;
		var maxy:Float = Math.NEGATIVE_INFINITY;
		var poly:Array<Float>;
		for (i in 0...levelEditor.polygonPointArray.length)
		{
			poly = levelEditor.polygonPointArray[i];
			for (j in 0...Std.int(poly.length / 2))
			{
				px = poly[j * 2];
				py = poly[j * 2 + 1];
				if (px < minx)
					minx = px;
				if (py < miny)
					miny = py;
				if (px > maxx)
					maxx = px;
				if (py > maxy)
					maxy = py;
			}
			
			if (AABBArray[i] == null)
			{
				AABBArray[i] = new AABB2D(minx, miny, maxx, maxy);
			}else
			{
				AABBArray[i].min.x = minx;
				AABBArray[i].min.y = miny;
				AABBArray[i].max.x = maxx;
				AABBArray[i].max.y = maxy;
			}
		}
	}
	
	public function drawPolygons():Void
	{
		clearAndRemove();
		var aabb:AABB2D;
		for (i in 0...levelEditor.polygonPointArray.length)
		{
			aabb = AABBArray[i];
			if (aabb.max.x < levelEditor.canvas.offsetX && aabb.max.y < levelEditor.canvas.offsetY)
				continue;
			if (aabb.min.x > (levelEditor.canvas.offsetX + levelEditor.canvas.width))
				continue;
			if (aabb.min.y > (levelEditor.canvas.offsetY + levelEditor.canvas.height))
				continue;
			if (polygonSpriteArray[i] == null)
				polygonSpriteArray[i] = new Sprite();
				
			if (levelEditor.polygonDataArray[i][0] == 0)
				polygonSpriteArray[i].graphics.lineStyle(2, 0x00FFFF);
			else if (levelEditor.polygonDataArray[i][0] == 1)
				polygonSpriteArray[i].graphics.lineStyle(2, 0xFF0000);
			drawPolygon(polygonSpriteArray[i].graphics, levelEditor.polygonPointArray[i]);
			canvasSprite.addChild(polygonSpriteArray[i]);
		}
	}
	
	public function drawPolygon(canvas:Graphics, pointArray:Array<Float>):Void
	{
		var p0:Vector2D = new Vector2D();
		var p1:Vector2D = new Vector2D();
		p0.x = pointArray[0] - levelEditor.canvas.offsetX;
		p0.y = pointArray[1] - levelEditor.canvas.offsetY;
		for (i in 1...Std.int(pointArray.length / 2))
		{
			p1.x = pointArray[i * 2] - levelEditor.canvas.offsetX;
			p1.y = pointArray[i * 2 + 1] - levelEditor.canvas.offsetY;
			drawClippedLine(canvas, p0, p1);
			p0.x = p1.x;
			p0.y = p1.y;
		}
		p1.x = pointArray[0] - levelEditor.canvas.offsetX;
		p1.y = pointArray[1] - levelEditor.canvas.offsetY;
		drawClippedLine(canvas, p0, p1);
	}
	
	public function clearAndRemove():Void
	{
		for (s in polygonSpriteArray)
		{
			if (s == null)
				continue;
			s.graphics.clear();
			if(canvasSprite.contains(s))
				canvasSprite.removeChild(s);
		}
	}
	
	
	public function drawClippedLine(canvas:Graphics, point0:Vector2D, point1:Vector2D):Void
	{
		var x0:Float = point0.x;
		var y0:Float = point0.y;
		var x1:Float = point1.x;
		var y1:Float = point1.y;
		
		var outcode0:Int = computeOutCode(point0);
		var outcode1:Int = computeOutCode(point1);
		
		var accept:Bool = false;
		
		while (true)
		{
			if (!(outcode0 | outcode1 != 0))
			{
				accept = true;
				break;
			}else if (outcode0 & outcode1 != 0)
			{
				break;
			}else 
			{
				var tx:Float;
				var ty:Float;
				
				var outcodeOut:Int = outcode0 != 0 ? outcode0 : outcode1;
				
				if (outcodeOut & 4 != 0)
				{
					tx = x0 + (x1 - x0) * (levelEditor.canvas.height - y0) / (y1 - y0);
					ty = levelEditor.canvas.height;
				}else if (outcodeOut & 8 != 0)
				{
					tx = x0 + (x1 - x0) * -y0 / (y1 - y0);
					ty = 0;
				}else if (outcodeOut & 2 != 0)
				{
					ty = y0 + (y1 - y0) * (levelEditor.canvas.width - x0) / (x1 - x0);
					tx = levelEditor.canvas.width;
				}else
				{
					ty = y0 + (y1 - y0) * x0 / (x1 - x0);
					tx = 0;
				}
				
				if (outcodeOut == outcode0)
				{
					x0 = tx;
					y0 = ty;
					outcode0 = computeOutCode(new Vector2D(x0, y0));
				} else
				{
					x1 = tx;
					y1 = ty;
					outcode1 = computeOutCode(new Vector2D(x1, y1));
				}
			}
		}
		//trace(accept);
		
		if (accept)
		{
			canvas.moveTo(x0, y0);
			canvas.lineTo(x1, y1);
		}
	}
	
	private function computeOutCode(p:Vector2D):Int
	{
		var code:Int = 0;
		//inside: 0
		//left: 1
		//right: 2
		//bottom: 4
		//top: 8
		if (p.x < 0)
			code |= 1;
		else if (p.x > levelEditor.canvas.width)
			code |= 2;
		if (p.y > levelEditor.canvas.height)
			code |= 4;
		else if (p.y < 0)
			code |= 8;
		return code;
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		switch(type)
		{
			case EditorEvent.MINIMAP_MOVE:
				drawPolygons();
		}
	}
}