package game;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.RigidBodyDefinition;
import flash.errors.Error;
import game.characters.DynamicEntityDefinition;
import game.scrolling.TileMap;

/**
 * ...
 * @author asdf
 */

class GameLevel 
{

	public var tileMapArray:Array<TileMap>;
	public var entityArray:Array<Array<DynamicEntityDefinition>>;
	public var groundBody:RigidBodyDefinition;
	
	public function new() 
	{
		tileMapArray = new Array<TileMap>();
		entityArray = new Array<Array<DynamicEntityDefinition>>();
		groundBody = new RigidBodyDefinition();
	}
	
	public function setTileLayer(map:TileMap, layer:Int):Void
	{
		if (layer < 0)
			throw new Error("layer must be greater than 0");
		tileMapArray[layer] = map;
	}
	
	public function addCharacter(def:DynamicEntityDefinition, layer:Int):Void
	{
		if (layer < 0)
			throw new Error("layer must be greater than 0");
		if (entityArray[layer] == null)
			entityArray[layer] = new Array<DynamicEntityDefinition>();
		entityArray[layer].push(def.clone());
	}
	
	public function addGroundShape(def:ShapeDefinition):Void
	{
		def.mass = 0;
		def.I = 0;
		def.collisionCategory = GameSettings.GROUND_COLLISION_CATEGORY;
		def.resolutionCategory = GameSettings.GROUND_COLLISION_CATEGORY;
		groundBody.addShape(def);
	}
}