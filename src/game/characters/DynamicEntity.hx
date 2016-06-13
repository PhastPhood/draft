package game.characters;
import draft.graphics.MolehillSprite;
import draft.graphics.MolehillSpriteDefinition;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.RigidBody;
import draft.physics.dynamics.RigidBodyDefinition;
import flash.geom.Rectangle;
import game.characters.kanye.KanyeCharacter;
import game.Game2D;
import game.GameLayer;

/**
 * ...
 * @author asdf
 */

class DynamicEntity 
{

	public static inline var NO_TYPE:Int = 0;
	public static inline var KANYE:Int = 0;
		
	public var body:RigidBody;
	public var spriteList:MolehillSprite;
	public var spriteCount:Int;
	public var visibleSpriteArray:Array<MolehillSprite>;
	public var entityType:Int;
	
	public var next:DynamicEntity;
	public var prev:DynamicEntity;
	
	public var layer:GameLayer;
	public var forceMultiplier:Float;

	public function new(data:DynamicEntityDefinition, layer:GameLayer) 
	{	
		entityType = NO_TYPE;
		
		this.layer = layer;
		
		spriteCount = data.spriteCount;
		var newSprite:MolehillSprite;
		var spriteDef:MolehillSpriteDefinition = data.spriteList;
		
		for (i in 0...spriteCount)
		{
			newSprite = Type.createInstance(MolehillSprite.getSpriteClass(spriteDef.spriteType), [spriteDef]);
			newSprite.init(layer.game.stagehand.context);
			newSprite.updateVertexBuffer();
			//append new shape to end of list
			if (spriteList == null)
			{
				spriteList = newSprite;
				spriteList.next = spriteList;
				spriteList.prev = spriteList;
			}else
			{
				newSprite.prev = spriteList.prev;
				spriteList.prev.next = newSprite;
				newSprite.next = spriteList;
				spriteList.prev = newSprite;
			}
			spriteDef = spriteDef.next;
		}
		
		body = layer.game.physicsEngine.addBody(data.bodyDefinition);
		forceMultiplier = body.mass / layer.game.dt * layer.game.physicsStepCount;
	}
	
	public static function getEntityClass(id:Int = NO_TYPE):Class<Dynamic>
	{
		if (id == KANYE)
			return KanyeCharacter;
		return DynamicEntity;
	}
	
	public function preUpdateEntity():Void
	{
		
	}
	
	public function postUpdateEntity():Void
	{
		
	}
	
	public function updateSprites():Void
	{
		
	}
	
	public function updateSpriteVisibility(viewPort:Rectangle):Void
	{
		
	}
	
	public function free():Void
	{
		var spriteWalker:MolehillSprite = spriteList;
		
		for (i in 0...spriteCount)
		{
			spriteWalker.free();
			spriteWalker = spriteWalker.next;
		}
		
		spriteList = null;
		if(body != null)
			body.free();
		spriteList = null;
		body = null;
		
		layer.removeEntity(this);
		
		untyped visibleSpriteArray.length = 0;
		visibleSpriteArray = null;
	}
	
}