package game;
import draft.graphics.MolehillSprite;
import draft.graphics.MolehillStagehand;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.physics.dynamics.forces.SimpleGravity;
import draft.physics.dynamics.RigidBody;
import draft.physics.PhysicsEngine;
import game.characters.DynamicEntity;
import game.characters.DynamicEntityDefinition;
import game.characters.kanye.KanyeCharacter;

/**
 * ...
 * @author asdf
 */

class Game2D implements IObserver
{
	public var characterCount:Int;
	
	public var camera:Camera2D;
	public var cameraControl:CameraControl;
	
	public var dt:Float;
	public var physicsStepCount:Int;
	
	public var stagehand:MolehillStagehand;
	public var physicsEngine:PhysicsEngine;
	
	public var groundBody:RigidBody;
	
	public var layerArray:Array<GameLayer>;
	public var layerCount:Int;
	
	public var entityArray:Array<DynamicEntity>;
	
	public var keyUpControl:KeyUpObservable;
	public var keyDownControl:KeyDownObservable;
	
	public var mainCharacter:KanyeCharacter;
	
	public var paused:Bool;
	public var debug:Bool;
	
	public var gravity:SimpleGravity;
	
	public function new(w:Int, h:Int) 
	{
		stagehand = new MolehillStagehand(w, h);
		camera = new Camera2D(w, h);
		physicsEngine = new PhysicsEngine();
		
		this.dt = GameSettings.INVERSE_FRAMERATE;
		physicsStepCount = GameSettings.PHYSICS_STEP_COUNT;
		
		layerArray = new Array<GameLayer>();
		entityArray = new Array<DynamicEntity>();
		
		keyUpControl = new KeyUpObservable();
		keyDownControl = new KeyDownObservable();
		keyDownControl.attach(this);
		
		cameraControl = new CameraControl(camera, null);
		
		paused = false;
		debug = false;
		
		gravity = new SimpleGravity(GameSettings.GRAVITY.x, GameSettings.GRAVITY.y);
		
		physicsEngine.addWorldForce(gravity);
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		if (type == UserEvent.KEY_DOWN)
		{
			if (data == 80)
			{
				debug = !debug;
				paused = !paused;
			}
			if (data == 83 && paused)
			{
				paused = false;
				step();
				paused = true;
			}
		}
	}
	
	public function loadLevel(gameLevel:GameLevel):Void
	{
		for (i in 0...gameLevel.tileMapArray.length)
		{
			if (gameLevel.tileMapArray[i] != null)
			{
				layerCount = i + 1;
				gameLevel.tileMapArray[i].tileSheet.init(stagehand.context);
				var l:GameLayer = new GameLayer(this);
				l.setMap(gameLevel.tileMapArray[i]);
				layerArray[i] = l;
			}
		}
		for (i in 0...gameLevel.entityArray.length)
		{
			if (gameLevel.entityArray[i] == null)
				continue;
			for (j in 0...gameLevel.entityArray[i].length)
			{
				if (gameLevel.entityArray[i][j] != null)
				{
					if (layerArray[i] == null)
						layerArray[i] = new GameLayer(this);
					//layerArray[i].addEntity(gameLevel.entityArray[i][j]);
					var ent:DynamicEntity = layerArray[i].addEntity(gameLevel.entityArray[i][j]);
					entityArray.push(ent);
					if (ent.entityType == DynamicEntity.KANYE)
					{
						mainCharacter = cast(ent, KanyeCharacter);
						camera.viewPort.x = mainCharacter.body.position.x - camera.viewPort.width * 0.5;
						camera.viewPort.y = mainCharacter.body.position.y - camera.viewPort.height * 0.5;
					}
				}
			}
		}
		
		cameraControl.player = mainCharacter;
		
		groundBody = physicsEngine.addBody(gameLevel.groundBody);
	}
	
	public function unloadLevel():Void
	{
		
	}
	
	public function step():Void
	{
		if (paused)
			return;
		var walker:DynamicEntity;
		for (l in layerArray)
		{
			if (l == null)
				continue;
			walker = l.entityList;
			for (i in 0...l.entityCount)
			{
				walker.preUpdateEntity();
				walker = walker.next;
			}
		}
		
		physicsEngine.step(dt, 10, GameSettings.PHYSICS_STEP_COUNT);
		cameraControl.positionCamera();
		
		for (l in layerArray)
		{
			if (l == null)
				continue;
			walker = l.entityList;
			for (i in 0...l.entityCount)
			{
				walker.postUpdateEntity();
				walker = walker.next;
			}
		}
		
		render();
	}
	
	public function render():Void
	{
		var layer:GameLayer;
		camera.updateMatrix();
		stagehand.beginDraw();
		var walker:DynamicEntity;
		for (i in 0...layerCount)
		{
			layer = layerArray[i];
			if (layer == null)
				continue;
				
			layer.updateBatch(camera.viewPort);
			stagehand.drawBatch(layer.tileMap.tileSheet.batchTexture, layer.batchVertices, camera.matrix);
			
			walker = layer.entityList;
			for (j in 0...layer.entityCount)
			{
				walker.updateSprites();
				walker.updateSpriteVisibility(camera.viewPort);
				for (s in walker.visibleSpriteArray)
				{
					if(s != null)
						stagehand.drawSprite(s, camera.matrix);
				}
				walker = walker.next;
			}
		}
		stagehand.endDraw();
	}
	
}