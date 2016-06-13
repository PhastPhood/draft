package ;
import draft.graphics.MolehillSprite;
import draft.graphics.MolehillSpriteDefinition;
import draft.graphics.MolehillStagehand;
import draft.graphics.Texture2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.collisions.shapes.definitions.RectangleDefinition;
import draft.physics.dynamics.forces.SimpleGravity;
import draft.physics.dynamics.forces.Spring;
import draft.physics.dynamics.Material;
import draft.physics.dynamics.RigidBody;
import draft.physics.dynamics.RigidBodyDefinition;
import draft.physics.PhysicsEngine;
import draft.utils.FPSMonitor;
import draft.utils.graphics.TextureUtils;
import draft.utils.MemoryMonitor;
import draft.utils.MonitorUtil;
import draft.utils.physics.PhysicsMonitor;
import flash.display.BitmapData;
import flash.display.Scene;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3D;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.drm.VoucherAccessInfo;
import flash.Vector;

/**
 * ...
 * @author asdf
 */

class PhysicsDemo extends Sprite
{

	public var world:PhysicsEngine;
	public var stagehand:MolehillStagehand;
	public var mouseSpring:Spring;
	public var tileImporter:TileImporter;
	public var mX:Float;
	public var mY:Float;
	
	public var boxBodyDef:RigidBodyDefinition;
	public var boxSpriteDef:MolehillSpriteDefinition;
	public var circleBodyDef:RigidBodyDefinition;
	public var circleSpriteDef:MolehillSpriteDefinition;
	public var starBodyDef:RigidBodyDefinition;
	public var starSpriteDef:MolehillSpriteDefinition;
	
	public var entityArray:Array<DemoEntity>;
	public var cameraMatrix:Matrix3D;
	public var orthoMatrix:Matrix3D;
	
	static function main()
	{
		var stage:Stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		stage.addChild(new PhysicsDemo());
	}
	
	public function new() 
	{
		super();
		Lib.current.stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initScene, false, 0, true);
	}
	
	public function initScene(_):Void
	{
		trace("ASDF");
		entityArray = new Array<DemoEntity>();
		cameraMatrix = new Matrix3D();
		cameraMatrix.identity();
		
		orthoMatrix = new Matrix3D(Vector.ofArray
		([
			2/640, 0  ,       0,        0,
			0  , 2/480,       0,        0,
			0  , 0  , 1/(100-0), -0/(100-0),
			0  , 0  ,       0,        1
		]));
		
		cameraMatrix.append(orthoMatrix);
		
		tileImporter = new TileImporter();
		world.addWorldForce(new SimpleGravity(0, 1400));
		mouseSpring = new Spring(new Vector2D(), 0, 0);
		world.addWorldForce(mouseSpring);
		
		var staticMaterial:Material = new Material(0, 0, 0);
		var groundDef:RigidBodyDefinition = new RigidBodyDefinition();
		var leftDef:RectangleDefinition = new RectangleDefinition(100, 480, staticMaterial);
		leftDef.localPosition.y = 240;
		leftDef.localPosition.x = -50;
		var rightDef:RectangleDefinition = new RectangleDefinition(100, 480, staticMaterial);
		rightDef.localPosition.y = 240;
		var bottomDef:RectangleDefinition = new RectangleDefinition(640, 100, staticMaterial);
		bottomDef.localPosition.x = 320;
		bottomDef.localPosition.y = 480;
		var topDef:RectangleDefinition = new RectangleDefinition(640, 100, staticMaterial);
		topDef.localPosition.x = 320;
		rightDef.localPosition.x = 640;
		groundDef.addShape(leftDef);
		groundDef.addShape(rightDef);
		groundDef.addShape(topDef);
		groundDef.addShape(bottomDef);
		world.addBody(groundDef);
		
		var gTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[1]);
		var gsDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(gTexture);
		gsDef.registrationPoint.x = 32;
		gsDef.registrationPoint.y = 32;
		gsDef.width = 640;
		gsDef.height = 100;
		var gDef:RectangleDefinition = new RectangleDefinition(640, 100, staticMaterial);
		var gbDef:RigidBodyDefinition = new RigidBodyDefinition();
		gbDef.addShape(gDef);
		gbDef.position.x = 320;
		gbDef.position.y = 480;
		addBody(gbDef, gsDef);
		
		/*
		var fccDef:CircleDefinition = new CircleDefinition(20, dynamicMaterial);
		fccDef.density = 7;
		var fcbDef:RigidBodyDefinition = new RigidBodyDefinition();
		fcbDef.addShape(fccDef);
		var fcTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[13]);
		//rcTexture.width = rcrDef.width;
		//rcTexture.height = rcrDef.height;
		scene.initTexture(fcTexture);
		var fcsDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(fcTexture);
		fcsDef.registrationPoint.x = 105;
		fcsDef.registrationPoint.y = 105;
		fcsDef.width = fccDef.radius * 2;
		fcsDef.height = fccDef.radius * 2;
		scene.initSpriteDefinition(fcsDef);
		shootDef = new DynamicEntityDefinition(fcbDef, fcsDef);*/
		var dynamicMaterial:Material = new Material(1, 0.5, 0);
		
		var brDef:RectangleDefinition = new RectangleDefinition(32, 32, dynamicMaterial);
		var bbDef:RigidBodyDefinition = new RigidBodyDefinition();
		bbDef.addShape(brDef);
		var bTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[1]);
		bTexture.width = 64;
		bTexture.height = 64;
		bTexture.uvRect.x = 0;
		bTexture.uvRect.y = 0;
		var bsDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(bTexture);
		bsDef.registrationPoint.x = 256;
		bsDef.registrationPoint.y = 256;
		bsDef.width = brDef.width;
		bsDef.height = brDef.height;
		
		bbDef.position.x = 600;
		for (i in 0...10)
		{
			bbDef.position.y = 430 - 35 * i;
			addBody(bbDef, bsDef);
		}
		
		var stats:MonitorUtil = new MonitorUtil();
		stats.x = 100;
		stats.y = 100;
		stats.addMonitor(new FPSMonitor());
		stats.addMonitor(new MemoryMonitor());
		stats.addMonitor(new PhysicsMonitor(world));
		//Lib.current.stage.addChild(new Bitmap(scene.tileLayerArray[2].displayBuffer));
		addChild(stats);
		
		stage.addEventListener(Event.ENTER_FRAME, step, false, 0, true);
	}
	
	public function onMouseMove(e:MouseEvent):Void
	{
		mX = e.stageX;
		mY = e.stageY;
	}
	
	/*public function onKeyDown(e:KeyboardEvent):Void
	{
		if (e.keyCode == 13 || e.keyCode == 32)
			return;
		shootDef.position.y = mY + 25;
		var e:DynamicEntity = scene.entityLayerArray[3].addEntity(shootDef);
		if (mX > 320)
		{
			
			shootDef.position.x = 640;
			e.body.velocity.x = -1000;
		}else
		{
			shootDef.position.x = 0;
			e.body.velocity.x = 1000;
		}
	}*/
	
	public function step(e:Event):Void
	{
		world.step(1 / 60, 10, 2);
		render();
	}
	
	public function render():Void
	{
		for (en in entityArray)
		{
			stagehand.drawSprite(en.sprite, new Matrix3D());
		}
	}
	
	public function addBody(bodyDef:RigidBodyDefinition, spriteDef:MolehillSpriteDefinition):Void
	{
		var entity:DemoEntity = new DemoEntity(bodyDef, spriteDef, world, stagehand);
		entityArray.push(entity);
	}
}

class DemoEntity
{
	public var body:RigidBody;
	public var sprite:MolehillSprite;
	
	public function new(bodyDef:RigidBodyDefinition, spriteDef:MolehillSpriteDefinition, world:PhysicsEngine, stagehand:MolehillStagehand)
	{
		body = world.addBody(bodyDef);
		sprite = new MolehillSprite(spriteDef);
		sprite.init(stagehand.context);
		sprite.updateVertexBuffer();
	}
	
	public function update():Void
	{
		sprite.position.x = body.worldCenterOfMass.x;
		sprite.position.y = body.worldCenterOfMass.y;
		sprite.rotation = body.getRotation();
		sprite.update();
	}
}

class TileImporter 
{

	public var bitmapDataArray:Array<BitmapData>;
	public function new() 
	{
		bitmapDataArray = new Array<BitmapData>();
		bitmapDataArray.push(new Soccer());//0
		bitmapDataArray.push(new Crate());//1
		bitmapDataArray.push(new Star());//2
	}
	
}
class Soccer extends BitmapData {public function new(){super(0,0);}}
class Crate extends BitmapData {public function new(){super(0,0);}}
class Star extends BitmapData {public function new(){super(0,0);}}