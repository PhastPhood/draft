package game.characters.kanye;
import draft.graphics.MolehillAnimatedSpriteDefinition;
import draft.graphics.MolehillSpriteDefinition;
import draft.graphics.Texture2D;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.collisions.shapes.definitions.RectangleDefinition;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.Material;
import draft.utils.graphics.TextureUtils;
import flash.geom.Rectangle;
import game.characters.DynamicEntity;
import game.characters.DynamicEntityDefinition;
import flash.display.BitmapData;
import game.GameSettings;

/**
 * ...
 * @author asdf
 */

class KanyeDefinition extends DynamicEntityDefinition
{

	
	public function new(bitmapDictionary:Map<String, BitmapData>) 
	{
		super(bitmapDictionary);
		entityType = DynamicEntity.KANYE;
	}
	
	override public function clone():DynamicEntityDefinition 
	{
		var c:DynamicEntityDefinition = new KanyeDefinition(bitmapDictionary);
		var spriteWalker:MolehillSpriteDefinition = spriteList;
		for (i in 0...spriteCount)
		{
			c.addSprite(spriteWalker);
			spriteWalker = spriteWalker.next;
		}
		
		c.bodyDefinition = bodyDefinition.clone();
		
		return c;
	}
	
	public override function createSpriteDefinitions(bitmapDictionary:Map<String, BitmapData>):Void
	{
		var kanyeMaterial:Material = new Material(1, 0, 0);
		var circleDef:CircleDefinition = new CircleDefinition(KanyeCharacter.COLLISION_RADIUS, new Material(0.01, 0, 0));
		//circleDef.resolutionCategory = 0x00010000;
		circleDef.localPosition.y = KanyeCharacter.CAPSULE_HEIGHT - 2 * KanyeCharacter.CAPSULE_RADIUS;
		circleDef.collisionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		circleDef.resolutionCategory = GameSettings.SENSOR_COLLISION_CATEGORY;
		bodyDefinition.addShape(circleDef);
		
		var circleDef2:CircleDefinition = new CircleDefinition(KanyeCharacter.CAPSULE_RADIUS, kanyeMaterial);
		circleDef2.localPosition.y = KanyeCharacter.CAPSULE_HEIGHT - 2 * KanyeCharacter.CAPSULE_RADIUS;
		circleDef2.collisionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		circleDef2.resolutionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		bodyDefinition.addShape(circleDef2);
		circleDef2.localPosition.y = 0;
		circleDef2.collisionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		circleDef2.resolutionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		bodyDefinition.addShape(circleDef2);
		
		var rectangleDef:RectangleDefinition = new RectangleDefinition(KanyeCharacter.CAPSULE_RADIUS * 2, KanyeCharacter.CAPSULE_HEIGHT - 2 * KanyeCharacter.CAPSULE_RADIUS, kanyeMaterial);
		rectangleDef.localPosition.y = (KanyeCharacter.CAPSULE_HEIGHT - 2 * KanyeCharacter.CAPSULE_RADIUS) * 0.5;
		rectangleDef.collisionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		rectangleDef.resolutionCategory = GameSettings.KANYE_COLLISION_CATEGORY;
		bodyDefinition.addShape(rectangleDef);
		
		bodyDefinition.I *= 2;
		
		bodyDefinition.centerOfMass.x = 0;
		bodyDefinition.centerOfMass.y = KanyeCharacter.CAPSULE_HEIGHT - 2 * KanyeCharacter.CAPSULE_RADIUS;
		
		var standingTexture:Texture2D = TextureUtils.makeTextureData(bitmapDictionary.get("standing"));
		var standingDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(standingTexture);
		standingDef.localPosition.x = -50 * KanyeCharacter.SCALE - bodyDefinition.centerOfMass.x;
		standingDef.localPosition.y = -115/2 * KanyeCharacter.SCALE - bodyDefinition.centerOfMass.y;
		addSprite(standingDef);
		
		var runningTexture:Texture2D = TextureUtils.makeTextureData(bitmapDictionary.get("running"));
		var runningDef:MolehillAnimatedSpriteDefinition = new MolehillAnimatedSpriteDefinition(runningTexture, 222.5, 263, 8, 1);
		runningDef.localPosition.x = -130 * KanyeCharacter.SCALE - bodyDefinition.centerOfMass.x;
		runningDef.localPosition.y = -100/2 * KanyeCharacter.SCALE - bodyDefinition.centerOfMass.y;
		addSprite(runningDef);
		
		var jumpingTexture:Texture2D = TextureUtils.makeTextureData(bitmapDictionary.get("jumping"));
		var jumpingDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(jumpingTexture);
		jumpingDef.localPosition.x = -80 * KanyeCharacter.SCALE - bodyDefinition.centerOfMass.x;
		jumpingDef.localPosition.y = -100/2 * KanyeCharacter.SCALE - bodyDefinition.centerOfMass.y;
		addSprite(jumpingDef);
		
	}
	
}