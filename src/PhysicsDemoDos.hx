package ;
import draft.graphics.MolehillSprite;
import draft.graphics.MolehillSpriteDefinition;
import draft.graphics.MolehillStagehand;
import draft.graphics.shaders.IShader2D;
import draft.graphics.shaders.obnoxious.SharpenShader;
import draft.graphics.shaders.SBMultiplierShader;
import draft.graphics.shaders.StandardShader;
import draft.graphics.Texture2D;
import draft.math.Vector2D;
import draft.physics.collisions.broadphase.strategies.BruteForce;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.collisions.shapes.definitions.PolygonDefinition;
import draft.physics.collisions.shapes.definitions.RectangleDefinition;
import draft.physics.collisions.shapes.definitions.ShapeDefinition;
import draft.physics.dynamics.forces.SimpleGravity;
import draft.physics.dynamics.forces.Spring;
import draft.physics.dynamics.Material;
import draft.physics.dynamics.RigidBody;
import draft.physics.dynamics.RigidBodyDefinition;
import draft.physics.PhysicsEngine;
import draft.utils.FPSMonitor;
import draft.utils.graphics.DrawStyle;
import draft.utils.graphics.DrawUtils;
import draft.utils.graphics.TextureUtils;
import draft.utils.MemoryMonitor;
import draft.utils.MonitorUtil;
import draft.utils.physics.PhysicsDraw;
import draft.utils.physics.PhysicsMonitor;
import draft.utils.physics.ShapeUtils;
import draft.utils.TextDisplay;
import flash.Boot;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.drm.VoucherAccessInfo;
import flash.text.TextField;
import flash.Vector;
import game.characters.kanye.KanyeDefinition;
import game.Game2D;
import game.GameLevel;
import game.scrolling.TileMap;
import game.scrolling.TileSettings;
import game.scrolling.TileSheet;

/**
 * ...
 * @author asdf
 */

class PhysicsDemoDos extends Sprite
{
	public static inline var SCREEN_WIDTH:Int = 640;
	public static inline var SCREEN_HEIGHT:Int = 480;

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
	
	public var startText:TextField;
	public var lastStarFrame:Int;
	
	public var shaderArray:Array<IShader2D>;
	public var shaderIndex:Int;
	
	public function new() 
	{
		super();
		stagehand = new MolehillStagehand(640, 480);
		world = new PhysicsEngine();
		Lib.current.stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onSceneCreate, false, 0, true);
		
	}
	
	public function onSceneCreate(_):Void
	{
		Lib.current.stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, onSceneCreate);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, initScene, false, 0, true);
		startText = new TextField();
		startText.selectable = false;
		startText.mouseEnabled = false;
		startText.condenseWhite = true;
		startText.multiline = true;
		startText.width = 500;
		startText.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#000000'>CLICK TO START <br /> PRESS B TO CREATE A BALL, C TO CREATE A CRATE, S TO CREATE A STAR <br /> PRESS D TO CHANGE GRAPHICS SHADER <br /> CLICK TO DRAG OBJECTS TO MOUSE POINTER </FONT>";
		startText.x = SCREEN_WIDTH * 0.5 - startText.textWidth * 0.5;
		startText.y = SCREEN_HEIGHT * 0.5 - startText.textHeight * 0.5;
		addChild(startText);
	}
	
	public function initScene(e:MouseEvent):Void
	{
		//removeChild(startText);
		lastStarFrame = 0;
		startText.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#000000'> <br /> PRESS B TO CREATE A BALL, C TO CREATE A CRATE, S TO CREATE A STAR <br /> PRESS D TO CHANGE GRAPHICS SHADER <br /> CLICK TO DRAG OBJECTS TO MOUSE POINTER </FONT>";
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, initScene);
		entityArray = new Array<DemoEntity>();
		cameraMatrix = new Matrix3D();
		cameraMatrix.identity();
		
		orthoMatrix = new Matrix3D(Vector.ofArray
		([
			2/SCREEN_WIDTH, 0  ,       0,        0,
			0  , 2/SCREEN_HEIGHT,       0,        0,
			0  , 0  , 1/(100-0), -0/(100-0),
			0  , 0  ,       0,        1
		]));
		
		cameraMatrix.appendTranslation(-SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5, 0);
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
		rightDef.localPosition.x = 640 + 50;
		groundDef.addShape(leftDef);
		groundDef.addShape(rightDef);
		groundDef.addShape(topDef);
		groundDef.addShape(bottomDef);
		world.addBody(groundDef);
		
		var gTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[3]);
		var gsDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(gTexture);
		gsDef.registrationPoint.x = 320;
		gsDef.registrationPoint.y = 50;
		gsDef.width = 640;
		gsDef.height = 100;
		var gDef:RectangleDefinition = new RectangleDefinition(640, 100, staticMaterial);
		var gbDef:RigidBodyDefinition = new RigidBodyDefinition();
		gbDef.addShape(gDef);
		gbDef.position.x = 320;
		gbDef.position.y = 480;
		addBody(gbDef, gsDef);
		gbDef.position.y = 0;
		addBody(gbDef, gsDef);
		
		var dynamicMaterial:Material = new Material(1, 0.5, 0);
		
		var fccDef:CircleDefinition = new CircleDefinition(20, dynamicMaterial);
		fccDef.density = 7;
		circleBodyDef = new RigidBodyDefinition();
		circleBodyDef.addShape(fccDef);
		var fcTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[0]);
		//rcTexture.width = rcrDef.width;
		//rcTexture.height = rcrDef.height;
		circleSpriteDef = new MolehillSpriteDefinition(fcTexture);
		circleSpriteDef.registrationPoint.x = 265;
		circleSpriteDef.registrationPoint.y = 265;
		circleSpriteDef.width = fccDef.radius * 2;
		circleSpriteDef.height = fccDef.radius * 2;
		
		circleBodyDef.position.x = 300;
		circleBodyDef.position.y = 400;
		
		addBody(circleBodyDef, circleSpriteDef);
		
		createStarDef(25, dynamicMaterial);
		starBodyDef.position.x = 400;
		starBodyDef.position.y = 300;
		var star:DemoEntity = addBody(starBodyDef, starSpriteDef);
		
		//PhysicsDraw.drawRigidBody(graphics, new DrawStyle(), star.body, false, new Vector2D());
		
		var brDef:RectangleDefinition = new RectangleDefinition(32, 32, dynamicMaterial);
		boxBodyDef = new RigidBodyDefinition();
		boxBodyDef.addShape(brDef);
		var bTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[1]);
		bTexture.width = 64;
		bTexture.height = 64;
		bTexture.uvRect.x = 0;
		bTexture.uvRect.y = 0;
		boxSpriteDef = new MolehillSpriteDefinition(bTexture);
		boxSpriteDef.registrationPoint.x = 256;
		boxSpriteDef.registrationPoint.y = 256;
		boxSpriteDef.width = brDef.width;
		boxSpriteDef.height = brDef.height;
		
		boxBodyDef.position.x = 600;
		for (i in 0...10)
		{
			boxBodyDef.position.y = 430 - 35 * i;
			addBody(boxBodyDef, boxSpriteDef);
		}
		
		
		var stats:MonitorUtil = new MonitorUtil();
		stats.x = 20;
		stats.y = 100;
		stats.addMonitor(new FPSMonitor());
		stats.addMonitor(new MemoryMonitor());
		stats.addMonitor(new PhysicsMonitor(world));
		//Lib.current.stage.addChild(new Bitmap(scene.tileLayerArray[2].displayBuffer));
		addChild(stats);
		
		stage.addEventListener(Event.ENTER_FRAME, step, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		
		shaderIndex = 0;
		createShaders();
		setShader();
	}
	
	public function createStarDef(side:Float, material:Material):Void
	{
		starBodyDef = new RigidBodyDefinition();
		
		var triangleDef:PolygonDefinition = new PolygonDefinition(ShapeUtils.createRegularPolygon(3, side), material);
		var pentDef:PolygonDefinition = new PolygonDefinition(ShapeUtils.createRegularPolygon(5, side), material);
		triangleDef.localRotation = Math.PI / 2;
		var pRadius:Float = side / (2 * Math.sin(Math.PI / 5));
		var tDisplacement:Float = pRadius * Math.cos(Math.PI / 5) + side / (Math.sqrt(3) * 2);
		
		var angle:Float = -Math.PI / 2;
		var tAngle:Float = 0;
		var dAngle:Float = Math.PI * 2 / 5;
		
		for (i in 0...5)
		{
			triangleDef.localRotation = angle;
			var dx:Float = tDisplacement * Math.cos(angle);
			var dy:Float = tDisplacement * Math.sin(angle);
			triangleDef.localPosition.x = dx;
			triangleDef.localPosition.y = dy;
			starBodyDef.addShape(triangleDef);
			angle -= dAngle;
			tAngle -= dAngle;
		}
		
		pentDef.localRotation = 18 / 180 * Math.PI;
		starBodyDef.addShape(pentDef);
		
		var h:Float = side * Math.sin(34 * Math.PI / 180) + 2 * tDisplacement + 10;
		var w:Float = 2 * side * Math.cos(12 * Math.PI / 180) + side;
		
		var sTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[2]);
		sTexture.uvRect.x = 0;
		sTexture.uvRect.y = 0;
		starSpriteDef = new MolehillSpriteDefinition(sTexture);
		starSpriteDef.registrationPoint.x = 475;
		starSpriteDef.registrationPoint.y = 906 * 1/(1 + Math.cos(36 * Math.PI / 180));
		starSpriteDef.width = w;
		starSpriteDef.height = h;
	}
	
	public function createShaders():Void
	{
		shaderArray = new Array<IShader2D>();
		shaderArray.push(new StandardShader(stagehand.context));
		shaderArray.push(new SharpenShader(stagehand.context));
		shaderArray.push(new SBMultiplierShader(stagehand.context));
	}
	
	public function setShader():Void
	{
		stagehand.shader = shaderArray[shaderIndex];
	}
	
	public function step(e:Event):Void
	{
		world.step(1 / 60, 10, 2);
		render();
		lastStarFrame++;
	}
	
	public function render():Void
	{
		stagehand.beginDraw();
		for (en in entityArray)
		{
			en.update();
			stagehand.drawSprite(en.sprite, cameraMatrix);
		}
		stagehand.endDraw();
	}
	
	public function addBody(bodyDef:RigidBodyDefinition, spriteDef:MolehillSpriteDefinition):DemoEntity
	{
		var entity:DemoEntity = new DemoEntity(bodyDef, spriteDef, world, stagehand);
		entityArray.push(entity);
		return entity;
	}
	
	public function onMouseMove(e:MouseEvent):Void
	{
		mX = e.stageX;
		mY = e.stageY;
		mouseSpring.point.x = mX;
		mouseSpring.point.y = mY;
		mouseSpring.updateForce();
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		mouseSpring.k = 10000;
		mouseSpring.b = 1000;
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		mouseSpring.updateForce();
	}
	
	public function onMouseUp(e:MouseEvent):Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		mouseSpring.k = 0;
		mouseSpring.b = 0;
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		mouseSpring.updateForce();
	}
	
	public function onKeyDown(e:KeyboardEvent):Void
	{
		var createShape:Bool = false;
		var shape:RigidBodyDefinition = null;
		var sprite:MolehillSpriteDefinition = null;
		if (e.keyCode == 66)
		{
			createShape = true;
			shape = circleBodyDef;
			sprite = circleSpriteDef;
		}else if (e.keyCode == 67)
		{
			createShape = true;
			shape = boxBodyDef;
			sprite = boxSpriteDef;
		}else if (e.keyCode == 83)
		{
			if (lastStarFrame > 20)
			{
				createShape = true;
				lastStarFrame = 0;
			}
			shape = starBodyDef;
			sprite = starSpriteDef;
		}else if (e.keyCode == 68)
		{
			shaderIndex++;
			shaderIndex %= 3;
			setShader();
		}
		if (!createShape)
		{
			return;
		}
		shape.position.x = mX;
		shape.position.y = mY;
		
		var entity:DemoEntity = addBody(shape, sprite);
		entity.body.velocity.y = -100;
		//entity.body.velocity.x = Math.random() * 100 - 50;
	}
	
	static function main()
	{
		var stage:Stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		stage.addChild(new PhysicsDemoDos());
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
		sprite.shaderData = [0.5, 1];
	}
	
	public function update():Void
	{
		sprite.position.x = body.worldCenterOfMass.x;
		sprite.position.y = body.worldCenterOfMass.y;
		sprite.rotation = body.getRotation() * 180/Math.PI;
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
		bitmapDataArray.push(new Stone());//3
	}
	
}
class Soccer extends BitmapData {public function new(){super(0,0);}}
class Crate extends BitmapData {public function new(){super(0,0);}}
class Star extends BitmapData {public function new(){super(0,0);}}
class Stone extends BitmapData {public function new(){super(0,0);}}