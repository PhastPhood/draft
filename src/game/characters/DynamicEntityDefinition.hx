package game.characters;
import draft.graphics.MolehillSpriteDefinition;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.RigidBodyDefinition;
import flash.display.BitmapData;

/**
 * ...
 * @author asdf
 */

class DynamicEntityDefinition 
{

	public var entityType:Int;
	
	public var bodyDefinition:RigidBodyDefinition;
	public var spriteList:MolehillSpriteDefinition;
	public var spriteCount:Int;
	
	public var bitmapDictionary:Map<String, BitmapData>;
	
	public function new(bitmapDictionary:Map<String, BitmapData>)
	{
		this.bitmapDictionary = bitmapDictionary;
		entityType = DynamicEntity.NO_TYPE;
		bodyDefinition = new RigidBodyDefinition();
		createSpriteDefinitions(bitmapDictionary);
	}
	
	public function clone():DynamicEntityDefinition
	{
		var c:DynamicEntityDefinition = new DynamicEntityDefinition(bitmapDictionary);
		var spriteWalker:MolehillSpriteDefinition = spriteList;
		for (i in 0...spriteCount)
		{
			c.addSprite(spriteWalker);
			spriteWalker = spriteWalker.next;
		}
		
		c.bodyDefinition = bodyDefinition.clone();
		return c;
	}
	
	public function addShape(shapeDef:ShapeDefinition):Void
	{
		bodyDefinition.addShape(shapeDef);
	}
	
	public function addSprite(spriteDef:MolehillSpriteDefinition):MolehillSpriteDefinition
	{
		var clone:MolehillSpriteDefinition = spriteDef.clone();
		
		if (spriteList == null)
		{
			spriteCount = 1;
			spriteList = clone;
			spriteList.next = spriteList;
			spriteList.prev = spriteList;
			return clone;
		}
		
		clone.prev = spriteList.prev;
		spriteList.prev.next = clone;
		clone.next = spriteList;
		spriteList.prev = clone;
		
		spriteCount++;
		return clone;
	}
	
	public function createSpriteDefinitions(bitmapDictionary:Map<String, BitmapData>):Void
	{
		
	}
	
}