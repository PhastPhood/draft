package game;
import draft.graphics.MolehillSprite;
import draft.graphics.MolehillSpriteDefinition;
import draft.graphics.MolehillStagehand;
import draft.graphics.Texture2D;
import draft.math.Vector2D;
import draft.utils.graphics.TextureUtils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import game.characters.DynamicEntity;
import game.characters.DynamicEntityDefinition;
import game.scrolling.TileMap;
import game.scrolling.TileSettings;

/**
 * ...
 * @author 
 */

class GameLayer 
{

	public var parallaxMultiplier:Float;
	public var localPosition:Vector2D;
	
	public var entityList:DynamicEntity;
	public var entityCount:Int;
	
	public var displayBuffer:BitmapData;
	public var tileMap:TileMap;
	public var batchVertices:Array<Float>;
	
	public var visible:Bool;
	
	public var game:Game2D;
	
	public function new(g:Game2D) 
	{
		parallaxMultiplier = 1;
		localPosition = new Vector2D();
		batchVertices = new Array<Float>();
		visible = true;
		game = g;
	}
	
	public function setMap(map:TileMap):Void
	{
		this.tileMap = map;
	}
	
	public function addEntity(entityDef:DynamicEntityDefinition):DynamicEntity
	{
		var c:Class<Dynamic> = DynamicEntity.getEntityClass(entityDef.entityType);
		var entity:DynamicEntity = Type.createInstance(c, [entityDef, this]);
		if (entityList == null)
		{
			entityList = entity;
			entityList.prev = entityList;
			entityList.next = entityList;
			entityCount++;
			return entity;
		}
		entity.prev = entityList.prev;
		entityList.prev.next = entity;
		entity.next = entityList;
		entityList.prev = entity;
		entityCount++;
		
		return entity;
	}
	
	public function removeEntity(e:DynamicEntity):Void
	{
		
	}
	
	public function updateBatch(viewPort:Rectangle):Void
	{
		if (tileMap == null)
			return;
		var x1:Int = Std.int(viewPort.x) >> TileSettings.TILE_BITS;
		var x2:Int = (Std.int(viewPort.x + viewPort.width) >> TileSettings.TILE_BITS) + 1;
		var y1:Int = Std.int(viewPort.y) >> TileSettings.TILE_BITS;
		var y2:Int = (Std.int(viewPort.y + viewPort.height) >> TileSettings.TILE_BITS) + 1;
		
		untyped batchVertices.length = 0;
		if (!visible)
			return;
		var vx1:Float;
		var vy1:Float;
		var vx2:Float;
		var vy2:Float;
		
		var uvRect:Rectangle;
		var uvx1:Float;
		var uvx2:Float;
		var uvy1:Float;
		var uvy2:Float;
		
		var borderX:Float = 0.5 / tileMap.tileSheet.batchTexture.width;
		var borderY:Float = 0.5 / tileMap.tileSheet.batchTexture.height;
		//trace(border);
		
		for (i in y1...y2)
		{
			if (i < tileMap.height && tileMap.data[i] != null)
			{
				for (j in x1...x2)
				{
					if (j < tileMap.width && tileMap.data[i][j] != 0)
					{
						vx1 = j << TileSettings.TILE_BITS;
						vy1 = i << TileSettings.TILE_BITS;
						vx2 = (j + 1) << TileSettings.TILE_BITS;
						vy2 = (i + 1) << TileSettings.TILE_BITS;
						//trace(vx1 + ", " + vx2 + ", " + vy1 + ", " + vy2);
						
						uvRect = tileMap.tileSheet.uvRectangleArray[tileMap.data[i][j]];
						
						uvx1 = uvRect.x + borderX;
						uvy1 = uvRect.y + borderY;
						uvx2 = uvRect.right - borderX;
						uvy2 = uvRect.bottom - borderY;
						
						//trace(uvy1 + ", " + uvy2);
						
						
						batchVertices.push(vx1);
						batchVertices.push(-vy2);
						batchVertices.push(uvx1);
						batchVertices.push(uvy2);
						
						batchVertices.push(vx1);
						batchVertices.push(-vy1);
						batchVertices.push(uvx1);
						batchVertices.push(uvy1);
						
						batchVertices.push(vx2);
						batchVertices.push(-vy1);
						batchVertices.push(uvx2);
						batchVertices.push(uvy1);
						
						batchVertices.push(vx2);
						batchVertices.push(-vy2);
						batchVertices.push(uvx2);
						batchVertices.push(uvy2);
						//batchVertices = batchVertices.concat(vdx);
						
					}
				}
			}
		}
	}
	

	
}