package editor.state;
import draft.math.Vector2D;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.scene.scrolling.TileMap;
import draft.scene.scrolling.TileSettings;
import editor.EditorEvent;
import editor.LevelEditor;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;

/**
 * ...
 * @author asdf
 */

class EditState extends EditorState, implements IObserver
{

	public var collisionMap:Array<Array<Array<Vector2D>>>;
	public var overlay:Sprite;
	public var pointHighlight:Sprite;
	public var selectedPoint:Vector2D;
	public var previousPoint:Vector2D;
	public var startingPoint:Vector2D;
	public var currentPolySprite:Sprite;
	public var setPolySprite:Sprite;
	public var resetSprite:Sprite;
	public var currentPoly:Array<Vector2D>;
	public var currentPointCount:Int;
	
	public function new(e:LevelEditor) 
	{
		super(e);
		collisionMap = new Array<Array<Array<Vector2D>>>();
		overlay = new Sprite();
		pointHighlight = new Sprite();
		setPolySprite = new Sprite();
		currentPolySprite = new Sprite();
		currentPoly = new Array<Vector2D>();
		resetSprite = new Sprite();
		resetSprite.graphics.lineStyle(1, 0xDCDCDC);
		resetSprite.graphics.beginFill(0xFFFFFF, 0);
		resetSprite.graphics.drawRect(0, 0, 640, 160);
		resetSprite.graphics.endFill();
		var resetText:TextField = new TextField();
		resetText.selectable = false;
		resetText.mouseEnabled = false;
		resetText.condenseWhite = true;
		resetText.width = 400;
		resetText.htmlText = "<FONT FACE = '_sans' SIZE = '14' COLOR = '#DCDCDC'><CENTER>" + "CLICK HERE TO RESET CURRENT COLLISION DATA" + "</CENTER></FONT>";
		resetSprite.addChild(resetText);
		resetSprite.y = 480;
		resetText.x = 140;
		resetText.y = 70;
	}
	
	override public function stateOn():Void
	{
		currentPointCount = 0;
		eraseCollisionMap();
		createCollisionMap();
		levelEditor.addChild(overlay);
		levelEditor.addChild(pointHighlight);
		levelEditor.addChild(setPolySprite);
		levelEditor.addChild(currentPolySprite);
		drawOverlay();
		drawFinishedPolygons();
		levelEditor.addChild(resetSprite);
		resetSprite.addEventListener(MouseEvent.MOUSE_DOWN, resetMouseDown, false, 0, true);
		levelEditor.minimap.attach(this);
		levelEditor.layerSelector.attach(this);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
		previousPoint = null;
	}
	
	override public function stateOff():Void
	{
		levelEditor.removeChild(overlay);
		levelEditor.removeChild(pointHighlight);
		levelEditor.removeChild(setPolySprite);
		levelEditor.removeChild(currentPolySprite);
		levelEditor.minimap.detach(this);
		levelEditor.removeChild(resetSprite);
		levelEditor.layerSelector.detach(this);
		resetSprite.removeEventListener(MouseEvent.MOUSE_DOWN, resetMouseDown);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		resetPoly();
	}
	
	public function resetMouseDown(e:MouseEvent):Void
	{
		resetPoly();
	}
	
	public function onMouseOver(e:MouseEvent):Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
	}
	
	public function onMouseOut(e:MouseEvent):Void
	{
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
		
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		if (currentPointCount == 0)
		{
			currentPoly.push(selectedPoint);
			startingPoint = selectedPoint;
			currentPointCount++;
			drawUnfinishedPoly();
		}else if (currentPointCount == 1)
		{
			currentPoly.push(selectedPoint);
			currentPointCount++;
			drawUnfinishedPoly();
		}else
		{
			if (selectedPoint == startingPoint)
			{
				finishPolygon();
				Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				return;
			}
			if (!checkPolygon(currentPoly.concat([selectedPoint])))
			{
				Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				return;
			}
			currentPoly.push(selectedPoint);
			currentPointCount++;
			drawUnfinishedPoly();
		}
		previousPoint = selectedPoint;
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}
	
	public function finishPolygon():Void
	{
		var newPoly:Array<Float> = new Array<Float>();
		for (p in currentPoly)
		{
			newPoly.push(p.x);
			newPoly.push(p.y);
		}
		levelEditor.polygonPointArray.push(newPoly);
		var newPolyData:Array<Float> = new Array<Float>();
		newPolyData[0] = 0;
		levelEditor.polygonDataArray.push(newPolyData);
		resetPoly();
		drawFinishedPolygons();
	}
	
	public function drawFinishedPolygons():Void
	{
		setPolySprite.graphics.clear();
		var p0:Vector2D = new Vector2D();
		var p1:Vector2D = new Vector2D();
		for (i in 0...levelEditor.polygonPointArray.length)
		{
			if (levelEditor.polygonDataArray[i][0] == 0)
				setPolySprite.graphics.lineStyle(2, 0x00FFFF);
			else if (levelEditor.polygonDataArray[i][0] == 1)
				setPolySprite.graphics.lineStyle(2, 0xFF0000);
			p0.x = levelEditor.polygonPointArray[i][0] - levelEditor.canvas.offsetX;
			p0.y = levelEditor.polygonPointArray[i][1] - levelEditor.canvas.offsetY;
			for (j in 1...Std.int(levelEditor.polygonPointArray[i].length/2))
			{
				p1.x = levelEditor.polygonPointArray[i][j * 2] - levelEditor.canvas.offsetX;
				p1.y = levelEditor.polygonPointArray[i][j * 2 + 1] - levelEditor.canvas.offsetY;
				drawClippedLine(setPolySprite.graphics, p0, p1);
				p0.x = p1.x;
				p0.y = p1.y;
			}
			p1.x = levelEditor.polygonPointArray[i][0] - levelEditor.canvas.offsetX;
			p1.y = levelEditor.polygonPointArray[i][1] - levelEditor.canvas.offsetY;
			drawClippedLine(setPolySprite.graphics, p0, p1);
		}
	}
	
	public function checkPolygon(pointArray:Array<Vector2D>):Bool
	{
		if (pointArray.length < 3)
			return true;
		
		var direction:Vector2D = new Vector2D();
		var i0:Int = 0;
		var i1:Int = 1;
		var index:Int;
		var p0:Vector2D = pointArray[0];
		var p1:Vector2D = pointArray[1];
		direction.x = p1.y - p0.y;
		direction.y = p0.x - p1.x;
		var initialSign:Float = direction.x * (pointArray[2].x - p0.x) + direction.y * (pointArray[2].y - p0.y);
		//trace(initialSign);
		
		for (i in 1...pointArray.length + 1)
		{
			if (i == pointArray.length)
				i1 = 0;
			else
				i1 = i;
			p1 = pointArray[i1];
			direction.x = p1.y - p0.y;
			direction.y = p0.x - p1.x;
			for (j in 0...pointArray.length)
			{
				if (j == i0 || j == i1)
					continue;
				if (initialSign * (direction.x * (pointArray[j].x - p0.x) + direction.y * (pointArray[j].y - p0.y)) <= 0)
					return false;
			}
			p0 = p1;
			i0 = i1;
		}
		
		var ax:Float = pointArray[0].x;
		var ay:Float = pointArray[0].y;
		var bx:Float = pointArray[1].x;
		var by:Float = pointArray[1].y;
		var cx:Float = pointArray[2].x;
		var cy:Float = pointArray[2].y;
		
		var u0:Float = ax - cx;
		var u1:Float = ay - cy;
		var v0:Float = bx - cx;
		var v1:Float = by - cy;
		
		if (u0 * v1 - v0 * u1 >= 0)
			return false;
		return true;
	}
	
	public function resetPoly():Void
	{
		previousPoint = null;
		selectedPoint = null;
		currentPolySprite.graphics.clear();
		untyped currentPoly.length = 0;
		currentPointCount = 0;
		startingPoint = null;
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		levelEditor.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		levelEditor.canvas.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
	}
	
	public function drawUnfinishedPoly():Void
	{
		if (currentPointCount == 0)
			return;
		currentPolySprite.graphics.clear();
		var p0:Vector2D = new Vector2D();
		p0.x = startingPoint.x - levelEditor.canvas.offsetX;
		p0.y = startingPoint.y - levelEditor.canvas.offsetY;
		currentPolySprite.graphics.lineStyle(2, 0x00FFFF);
		if (computeOutCode(p0) == 0)	
			currentPolySprite.graphics.drawCircle(p0.x, p0.y, 3);
		var p1:Vector2D = new Vector2D();
		if (currentPointCount == 1)
			return;
		for (i in 1...currentPoly.length)
		{
			p1.x = currentPoly[i].x - levelEditor.canvas.offsetX;
			p1.y = currentPoly[i].y - levelEditor.canvas.offsetY;
			if (computeOutCode(p1) == 0)
				currentPolySprite.graphics.drawCircle(p1.x, p1.y, 3);
			drawClippedLine(currentPolySprite.graphics, p0, p1);
			p0.x = p1.x;
			p0.y = p1.y;
		}
	}
	
	public function drawFinishedPoly():Void
	{
		currentPolySprite.graphics.clear();
		var p0:Vector2D = new Vector2D();
		p0.x = startingPoint.x - levelEditor.canvas.offsetX;
		p0.y = startingPoint.y - levelEditor.canvas.offsetY;
		currentPolySprite.graphics.lineStyle(3, 0x00FFFF);
		var p1:Vector2D = new Vector2D();
		if (currentPointCount == 1)
			return;
		for (i in 1...currentPoly.length)
		{
			p1.x = currentPoly[i].x - levelEditor.canvas.offsetX;
			p1.y = currentPoly[i].y - levelEditor.canvas.offsetY;
			drawClippedLine(currentPolySprite.graphics, p0, p1);
			p0.x = p1.x;
			p0.y = p1.y;
		}
		
		p1.x = startingPoint.x - levelEditor.canvas.offsetX;
		p1.y = startingPoint.y - levelEditor.canvas.offsetY;
		drawClippedLine(currentPolySprite.graphics, p0, p1);
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
	
	public function onMouseMove(e:MouseEvent):Void
	{
		if (currentPointCount > 2)
			drawUnfinishedPoly();
		
		pointHighlight.graphics.clear();
		var radius:Float = 7;
		
		selectedPoint = null;
		var globalMouseX:Float = e.localX + levelEditor.canvas.offsetX;
		var globalMouseY:Float = e.localY + levelEditor.canvas.offsetY;
		var globalTileX:Int = Std.int(globalMouseX / TileSettings.TILE_SIZE);
		var globalTileY:Int = Std.int(globalMouseY / TileSettings.TILE_SIZE);
		
		var startX:Int = globalTileX - 1;
		var startY:Int = globalTileY - 1;
		var endX:Int = globalTileX + 1;
		var endY:Int = globalTileY + 1;
		
		startX = startX < 0 ? 0 : startX;
		startY = startY < 0 ? 0 : startY;
		endX = endX > levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width ? levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width : endX;
		endY = endY > levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height ? levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height : endY;
		
		var minDistance:Float = Math.POSITIVE_INFINITY;
		var distance:Float;
		var dx:Float;
		var dy:Float;
		for (i in startY...endY)
		{
			if (collisionMap[i] == null)
				continue;
			for (j in startX...endX)
			{
				if (collisionMap[i][j] == null)
					continue;
				for (k in 0...collisionMap[i][j].length)
				{
					dx = globalMouseX - collisionMap[i][j][k].x;
					dy = globalMouseY - collisionMap[i][j][k].y;
					
					distance = dx * dx + dy * dy;
					if (distance < radius * radius)
					{
						if (distance < minDistance)
						{
							selectedPoint = collisionMap[i][j][k];
							minDistance = distance;
						}
					}
				}
			}
		}
		pointHighlight.graphics.lineStyle(1, 0x00FFFF);
		if (selectedPoint != null)
		{
			pointHighlight.graphics.drawCircle(selectedPoint.x - levelEditor.canvas.offsetX, selectedPoint.y - levelEditor.canvas.offsetY, radius);
		}else
		{
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			return;
		}
		
		if (currentPointCount == 0)
		{
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			return;
		}
		
		var p0:Vector2D = new Vector2D(previousPoint.x - levelEditor.canvas.offsetX, previousPoint.y - levelEditor.canvas.offsetY);
		var p1:Vector2D = new Vector2D(selectedPoint.x - levelEditor.canvas.offsetX, selectedPoint.y - levelEditor.canvas.offsetY);
		if (currentPointCount == 1)
		{
			pointHighlight.graphics.lineStyle(2, 0x00FFFF);
			drawClippedLine(pointHighlight.graphics, p0, p1);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}else
		{
			if (selectedPoint == startingPoint)
			{
				drawFinishedPoly();
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			}else
			{
				var ar:Array<Vector2D> = currentPoly.concat([selectedPoint]);
				if (!checkPolygon(ar))
					return;
				pointHighlight.graphics.lineStyle(2, 0x00FFFF);
				drawClippedLine(pointHighlight.graphics, p0, p1);
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			}
		}
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		switch(type)
		{
			case EditorEvent.MINIMAP_MOVE:
				drawOverlay();
				drawUnfinishedPoly();
				drawFinishedPolygons();
			case EditorEvent.LAYER_CHANGE:
				eraseCollisionMap();
				createCollisionMap();
				drawOverlay();
				resetPoly();
		}
	}
	
	public function drawOverlay():Void
	{
		var startX:Int = Std.int(levelEditor.canvas.offsetX / TileSettings.TILE_SIZE);
		var startY:Int = Std.int(levelEditor.canvas.offsetY / TileSettings.TILE_SIZE);
		var endX:Int = Std.int((levelEditor.canvas.offsetX + levelEditor.canvas.width) / TileSettings.TILE_SIZE) + 1;
		var endY:Int = Std.int((levelEditor.canvas.offsetY + levelEditor.canvas.height) / TileSettings.TILE_SIZE) + 1;
		
		overlay.graphics.clear();
		overlay.graphics.lineStyle(1, 0x00FFFF);
		var drawX:Float;
		var drawY:Float;
		
		startX = startX < 0 ? 0 : startX;
		startY = startY < 0 ? 0 : startY;
		endX = endX > levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width ? levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.width : endX;
		endY = endY > levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height ? levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap.height : endY;
		
		for (i in startY...endY)
		{
			if (collisionMap[i] == null)
				continue;
			for (j in startX...endX)
			{
				if (collisionMap[i][j] == null)
					continue;
				for (k in 0...collisionMap[i][j].length)
				{
					drawX = collisionMap[i][j][k].x - levelEditor.canvas.offsetX;
					drawY = collisionMap[i][j][k].y - levelEditor.canvas.offsetY;
					if (computeOutCode(new Vector2D(drawX, drawY)) != 0)
						continue;
					overlay.graphics.moveTo(drawX - 2, drawY - 2);
					overlay.graphics.lineTo(drawX + 2, drawY + 2);
					overlay.graphics.moveTo(drawX - 2, drawY + 2);
					overlay.graphics.lineTo(drawX + 2, drawY - 2);
				}
			}
		}
	}
	
	public function eraseCollisionMap():Void
	{
		for (i in 0...collisionMap.length)
		{
			for (j in 0...collisionMap[i].length)
			{
				untyped collisionMap[i][j].length = 0;
			}
		}
	}
	
	public function createCollisionMap():Void
	{
		var tileMap:TileMap = levelEditor.scene.tileLayerArray[levelEditor.currentLayer].tileMap;
		var initialPointMap:Array<Array<Array<Vector2D>>> = new Array<Array<Array<Vector2D>>>();
		var tilePoints:Array<Vector2D>;
		var mod:Float;
		for (i in 0...tileMap.height)
		{
			initialPointMap[i] = new Array<Array<Vector2D>>();
			for (j in 0...tileMap.width)
			{
				initialPointMap[i][j] = new Array<Vector2D>();
				tilePoints = levelEditor.collisionSheets[0].points[tileMap.data[i][j]];
				if (tilePoints == null)
					continue;
				for (k in 0...tilePoints.length)
				{
					var insertedPoint:Vector2D = new Vector2D(tilePoints[k].x, tilePoints[k].y);
					mod = insertedPoint.x % TileSettings.TILE_SIZE;
					if (mod == -1 || mod == TileSettings.TILE_SIZE - 1)
						insertedPoint.x += 1;
					if (mod == 1 || mod == -TileSettings.TILE_SIZE + 1)
						insertedPoint.x -= 1;
					mod = insertedPoint.y % TileSettings.TILE_SIZE;
					if (mod == -1 || mod == TileSettings.TILE_SIZE - 1)
						insertedPoint.y += 1;
					if (mod == 1 || mod == -TileSettings.TILE_SIZE + 1)
						insertedPoint.y -= 1;
					insertedPoint.x += j * TileSettings.TILE_SIZE;
					insertedPoint.y += i * TileSettings.TILE_SIZE;
					initialPointMap[i][j].push(insertedPoint);
				}
			}
		}
		
		var deletedModifier:Int = 0;
		var deletedModifier2:Int = 0;
		var arraysToCheck:Array<Array<Vector2D>> = new Array<Array<Vector2D>>();
		var arrayCheckCount:Int = 0;
		var pointAverageCount:Int = 0;
		var pointToCheck:Vector2D;
		var point2:Vector2D;
		var localX:Float;
		var localY:Float;
		var delete:Bool;
		var n:Int;
		for (i in 0...tileMap.height)
		{
			if (collisionMap[i] == null)
				collisionMap[i] = new Array<Array<Vector2D>>();
			for (j in 0...tileMap.width)
			{
				if (collisionMap[i][j] == null)
					collisionMap[i][j] = new Array<Vector2D>();
				deletedModifier = 0;
				n = initialPointMap[i][j].length;
				for (k in 0...n)
				{
					pointToCheck = initialPointMap[i][j][k - deletedModifier];
					//trace(k + ", " + deletedModifier + ", " + n);
					localX = pointToCheck.x - j * TileSettings.TILE_SIZE;
					localY = pointToCheck.y - i * TileSettings.TILE_SIZE;
					arrayCheckCount = 0;
					if (localX == 0)
					{
						if (j > 0)
						{
							arrayCheckCount = 1;
							arraysToCheck[0] = initialPointMap[i][j - 1];
							if (localY == 0)
							{
								if (i > 0)
								{
									arrayCheckCount = 3;
									arraysToCheck[1] = initialPointMap[i - 1][j];
									arraysToCheck[2] = initialPointMap[i - 1][j - 1];
								}
							}else if (localY == TileSettings.TILE_SIZE)
							{
								if (i < tileMap.height - 1)
								{
									arrayCheckCount = 3;
									arraysToCheck[1] = initialPointMap[i + 1][j];
									arraysToCheck[2] = initialPointMap[i + 1][j - 1];
								}
							}
						}else if (localY == 0)
						{
							if (i > 0)
							{
								arrayCheckCount = 1;
								arraysToCheck[0] = initialPointMap[i - 1][j];
							}
						}else if (localY == TileSettings.TILE_SIZE)
						{
							if (i < tileMap.height - 1)
							{
								arrayCheckCount = 1;
								arraysToCheck[0] = initialPointMap[i + 1][j];
							}
						}
					}else if (localX == TileSettings.TILE_SIZE)
					{
						if (j < tileMap.width - 1)
						{
							arrayCheckCount = 1;
							arraysToCheck[0] = initialPointMap[i][j + 1];
							if (localY == 0)
							{
								if (i > 0)
								{
									arrayCheckCount = 3;
									arraysToCheck[1] = initialPointMap[i - 1][j];
									arraysToCheck[2] = initialPointMap[i - 1][j + 1];
								}
							}else if (localY == TileSettings.TILE_SIZE)
							{
								if (i < tileMap.height - 1)
								{
									arrayCheckCount = 3;
									arraysToCheck[1] = initialPointMap[i + 1][j];
									arraysToCheck[2] = initialPointMap[i + 1][j + 1];
								}
							}
						}else if (localY == 0)
						{
							if (i > 0)
							{
								arrayCheckCount = 1;
								arraysToCheck[0] = initialPointMap[i - 1][j];
							}
						}else if (localY == TileSettings.TILE_SIZE)
						{
							if (i < tileMap.height - 1)
							{
								arrayCheckCount = 1;
								arraysToCheck[0] = initialPointMap[i + 1][j];
							}
						}
					}else if (localY == 0)
					{
						if (i > 0)
						{
							arrayCheckCount = 1;
							arraysToCheck[0] = initialPointMap[i - 1][j];
						}						
					}else if (localY == TileSettings.TILE_SIZE)
					{
						if (i < tileMap.height - 1)
						{
							arrayCheckCount = 1;
							arraysToCheck[0] = initialPointMap[i + 1][j];
						}						
					}else
					{
						collisionMap[i][j].push(pointToCheck);
						continue;
					}
					var newPoint:Vector2D = pointToCheck.clone();
					pointAverageCount = 1;
					delete = false;
					for (l in 0...arrayCheckCount)
					{
						deletedModifier2 = 0;
						for (m in 0...arraysToCheck[l].length)
						{
							point2 = arraysToCheck[l][m - deletedModifier2];
							if (Math.abs(point2.x - pointToCheck.x) <= 1)
							{
								if (Math.abs(point2.y - pointToCheck.y) <= 1)
								{
									newPoint.x += point2.x;
									newPoint.y += point2.y;
									pointAverageCount++;
									deletedModifier2++;
									delete = true;
									arraysToCheck[l].remove(point2);
								}
							}
						}
					}
					if (delete)
					{
						deletedModifier++;
						initialPointMap[i][j].remove(pointToCheck);
					}
					newPoint.x /= pointAverageCount;
					newPoint.y /= pointAverageCount;
					collisionMap[i][j].push(newPoint);
				}
				
			}
		}
	}
	
	
	
}