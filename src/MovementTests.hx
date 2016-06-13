package ;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.PolygonDefinition;
import draft.physics.collisions.shapes.definitions.RectangleDefinition;
import draft.physics.dynamics.forces.SimpleGravity;
import draft.physics.dynamics.Material;
import draft.utils.FPSMonitor;
import draft.utils.graphics.DrawStyle;
import draft.utils.graphics.DrawUtils;
import draft.utils.MemoryMonitor;
import draft.utils.MonitorUtil;
import draft.utils.physics.PhysicsDraw;
import draft.utils.physics.PhysicsMonitor;
import draft.utils.TextDisplay;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.text.TextField;
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

class MovementTests extends Sprite
{

	public static inline var TILE_COUNT_H:Int = 50;
	public static inline var TILE_COUNT_V:Int = 75;
	
	public static inline var TILE_WIDTH:Float = TileSettings.TILE_SIZE;
	
	public var tempGraphics:TemporaryGraphics;
	public var globalAssets:GlobalAssets;
	
	public var map1:TileMap;
	public var sheet1:TileSheet;
	
	public var startText:TextField;
	
	public var gravity:SimpleGravity;
	
	public var tDisplay:TextDisplay;
	
	public var testGame:Game2D;
	
	public function new() 
	{
		super();
		tempGraphics = new TemporaryGraphics();
		globalAssets = new GlobalAssets();
		
		testGame = new Game2D(720, 540);
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
		startText.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#000000'>CLICK TO START <br /> MOVE: LEFT + RIGHT <br /> JUMP: Z </FONT>";
		startText.x = 720 * 0.5 - startText.textWidth * 0.5;
		startText.y = 540 * 0.5 - startText.textHeight * 0.5;
		addChild(startText);
	}
	
	public function initScene(e:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, initScene);
		removeChild(startText);
		
		var level:GameLevel = new GameLevel();
		
		var ar:Array<Array<Int>> = [];
		for (i in 0...1)
		{
			for (j in 0...13)
			{
				ar.push([j * 64, i * 64, 64, 64]);
			}
		}
		
		sheet1 = new TileSheet(tempGraphics.graphicsArray[0], ar);
		
		map1 = new TileMap(TILE_COUNT_H, TILE_COUNT_V, sheet1);
		
		for (i in 0...TILE_COUNT_H)
		{
			for (j in 0...TILE_COUNT_V)
			{
				map1.data[j][i] = 0;
			}
		}
		
		for (i in 0...TILE_COUNT_V)
		{
			map1.data[i][0] = 2;
			map1.data[i][TILE_COUNT_H - 1] = 2;
		}
		
		for (i in 0...TILE_COUNT_H)
		{
			map1.data[0][i] = 2;
			map1.data[TILE_COUNT_V - 1][i] = 2;
		}
		
		for (i in 1...TILE_COUNT_H - 20)
		{
			map1.data[TILE_COUNT_V - 2][i] = 2;
			map1.data[TILE_COUNT_V - 3][i - 1] = 2;
			map1.data[TILE_COUNT_V - 4][i - 2] = 2;
			map1.data[TILE_COUNT_V - 5][i - 3] = 2;
		}
		
		var slowSlopes:Bool = true;
		
		if (slowSlopes)
		{		
			map1.data[TILE_COUNT_V - 4][-1] = 0;
			map1.data[TILE_COUNT_V - 4][-2] = 0;
			map1.data[TILE_COUNT_V - 5][-1] = 0;
			map1.data[TILE_COUNT_V - 5][-2] = 0;
			map1.data[TILE_COUNT_V - 5][-3] = 0;
			map1.data[TILE_COUNT_V - 2][TILE_COUNT_H - 20] = 4;
			map1.data[TILE_COUNT_V - 3][TILE_COUNT_H - 21] = 4;
			map1.data[TILE_COUNT_V - 4][TILE_COUNT_H - 22] = 4;
			map1.data[TILE_COUNT_V - 5][TILE_COUNT_H - 23] = 4;
			map1.data[TILE_COUNT_V - 2][TILE_COUNT_H - 20] = 9;
			map1.data[TILE_COUNT_V - 2][TILE_COUNT_H - 19] = 10;
			
			map1.data[TILE_COUNT_V - 8][TILE_COUNT_H - 42] = 9;
			map1.data[TILE_COUNT_V - 8][TILE_COUNT_H - 41] = 10;
			map1.data[TILE_COUNT_V - 7][TILE_COUNT_H - 40] = 9;
			map1.data[TILE_COUNT_V - 7][TILE_COUNT_H - 39] = 10;
			map1.data[TILE_COUNT_V - 6][TILE_COUNT_H - 38] = 9;
			map1.data[TILE_COUNT_V - 6][TILE_COUNT_H - 37] = 10;
			
			for (i in TILE_COUNT_H - 43...TILE_COUNT_H - 38)
			{
				map1.data[TILE_COUNT_V - 6][i] = 2;
			}
			
			for (i in TILE_COUNT_H - 43...TILE_COUNT_H - 40)
			{
				map1.data[TILE_COUNT_V - 7][i] = 2;
			}
			
			map1.data[TILE_COUNT_V - 8][TILE_COUNT_H - 43] = 2;
		}
		
		var kanyeDef:KanyeDefinition = new KanyeDefinition(globalAssets.kanyeGraphics);
		kanyeDef.bodyDefinition.position.x = 50;
		kanyeDef.bodyDefinition.position.y = 50;
		level.addCharacter(kanyeDef, 3);
		/*
		kanyeDef.bodyDefinition.position.x = 150;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 250;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 350;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 450;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.y = 250;
		kanyeDef.bodyDefinition.position.x = 50;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 150;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 250;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 350;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 450;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.y = 450;
		kanyeDef.bodyDefinition.position.x = 50;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 150;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 250;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 350;
		level.addCharacter(kanyeDef, 3);
		kanyeDef.bodyDefinition.position.x = 450;
		level.addCharacter(kanyeDef, 3);
		//*/
		
		var staticMaterial:Material = new Material(0, 0, 0);
		var rectDef1:RectangleDefinition = new RectangleDefinition(TILE_COUNT_H * TILE_WIDTH, TILE_WIDTH, staticMaterial);
		rectDef1.localPosition.x = TILE_COUNT_H * TILE_WIDTH * 0.5;
		rectDef1.localPosition.y = TILE_WIDTH * 0.5;
		level.addGroundShape(rectDef1);
		rectDef1.localPosition.y = TILE_WIDTH * 0.5 + (TILE_COUNT_V - 1) * TILE_WIDTH;
		//rectDef1.localRotation = 0.5;
		level.addGroundShape(rectDef1);
		var rectDef2:RectangleDefinition = new RectangleDefinition(TILE_WIDTH, TILE_WIDTH * TILE_COUNT_V, staticMaterial);
		rectDef2.localPosition.x = TILE_WIDTH * 0.5;
		rectDef2.localPosition.y = TILE_COUNT_V * TILE_WIDTH * 0.5;
		level.addGroundShape(rectDef2);
		rectDef2.localPosition.x = TILE_WIDTH * 0.5 + (TILE_COUNT_H - 1) * TILE_WIDTH;
		level.addGroundShape(rectDef2);
		var rectDef3:RectangleDefinition = new RectangleDefinition((TILE_COUNT_H - 19) * TILE_WIDTH, TILE_WIDTH, staticMaterial);
		rectDef3.localPosition.x = (TILE_COUNT_H - 27) * TILE_WIDTH * 0.5;
		rectDef3.localPosition.y = TILE_WIDTH * 0.5 + (TILE_COUNT_V - 5) * TILE_WIDTH;
		level.addGroundShape(rectDef3);
		var triangleDef:RectangleDefinition = new RectangleDefinition(TILE_WIDTH * 4 * Math.sqrt(2), TILE_WIDTH * 4 * Math.sqrt(2), staticMaterial);
		triangleDef.localPosition.x = (TILE_COUNT_H - 23) * TILE_WIDTH;
		triangleDef.localPosition.y = TILE_WIDTH + (TILE_COUNT_V - 2) * TILE_WIDTH;
		triangleDef.localRotation = Math.PI / 4;
		level.addGroundShape(triangleDef);
		var triangleDef2:PolygonDefinition = new PolygonDefinition([0, 0, 64, 0, 0, -32], staticMaterial);
		triangleDef2.localPosition.x = (TILE_COUNT_H - 20) * TILE_WIDTH;
		triangleDef2.localPosition.y = (TILE_COUNT_V - 1) * TILE_WIDTH;
		level.addGroundShape(triangleDef2);
		var triangleDef3:PolygonDefinition = new PolygonDefinition([-32, 0,  64 * 3, 0, 0, -32 * 3, -32, -32 * 3], staticMaterial);
		triangleDef3.localPosition.x = (TILE_COUNT_H - 42) * TILE_WIDTH;
		triangleDef3.localPosition.y = (TILE_COUNT_V - 5) * TILE_WIDTH;
		level.addGroundShape(triangleDef3);
		
		level.setTileLayer(map1, 3);
		testGame.loadLevel(level);
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		
		var stats:MonitorUtil = new MonitorUtil();
		stats.x = 100;
		stats.y = 100;
		stats.addMonitor(new FPSMonitor());
		stats.addMonitor(new MemoryMonitor());
		stats.addMonitor(new PhysicsMonitor(testGame.physicsEngine));
		tDisplay = new TextDisplay(" ");
		stats.addMonitor(tDisplay);
		addChild(stats);
		
		var data:BitmapData = new GlobalAssets().kanyeGraphics.get("legsRunning");
		
		var asdf:Array<Vector2D> = new Array<Vector2D>();
		asdf[2] = new Vector2D();
	}
	
	public function onEnterFrame(e:Event):Void
	{
		testGame.step();
		var st:String = testGame.mainCharacter.body.velocity.toString();
		//tDisplay.setText(st.substr(1, st.length - 2));
		tDisplay.setText(Std.string(testGame.mainCharacter.currentState == testGame.mainCharacter.fallingState) + 
		"<br />" + testGame.mainCharacter.groundNormal.toString().substr(2, 10));
		/*
		var style:DrawStyle = new DrawStyle();
		var offset:Vector2D = new Vector2D();
		offset.x = -testGame.camera.viewPort.x;
		offset.y = -testGame.camera.viewPort.y;
		graphics.clear();
		PhysicsDraw.drawRigidBody(graphics, style, testGame.mainCharacter.body, false, offset);//*/
	}
	
	static function main()
	{
		var stage:Stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		stage.addChild(new MovementTests());
	}
	
}