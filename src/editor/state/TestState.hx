package editor.state;
import draft.game.Game;
import draft.game.GameEvent;
import draft.graphics.MolehillSpriteDefinition;
import draft.graphics.Texture2D;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.physics.collisions.broadphase.strategies.SpatialHash;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.collisions.shapes.definitions.PolygonDefinition;
import draft.physics.collisions.shapes.definitions.RectangleDefinition;
import draft.physics.dynamics.Material;
import draft.physics.dynamics.RigidBodyDefinition;
import draft.physics.PhysicsEngine;
import draft.scene.entity.DynamicEntityDefinition;
import draft.scene.scrolling.TileSettings;
import draft.utils.graphics.TextureUtils;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;

/**
 * ...
 * @author asdf
 */

class TestState extends EditorState, implements IObserver
{
	public var playerSprite:Bitmap;
	public var playerDef:DynamicEntityDefinition;
	public var game:Game;
	public var screen:Sprite;
	public function new(e:editor.LevelEditor) 
	{
		super(e);
		playerSprite = new Bitmap(levelEditor.tileImporter.bitmapDataArray[9]);
		game = new Game(levelEditor.scene);
		screen = new Sprite();
		screen.graphics.lineStyle(1, 0x00FFFF);
		screen.graphics.beginFill(0xFFFFFF, 0);
		screen.graphics.drawRect(0, 0, levelEditor.canvas.width, levelEditor.canvas.height);
		
		var playerMaterial:Material = new Material(1, 0, 0);
		//var playerShapeDef:CircleDefinition = new CircleDefinition(TileSettings.TILE_SIZE, playerMaterial);
		//var playerShapeDef:RectangleDefinition = new RectangleDefinition(32, 64, playerMaterial);
		//var playerShapeDef:PolygonDefinition = new PolygonDefinition([16.0, -32, -16, -32, -16, 27, -11, 32, 11, 32, 16, 27], playerMaterial);
		//var playerShapeDef:PolygonDefinition = new PolygonDefinition([16.0, -27, 11, -32, -11, -32, -16, -27, -16, 27, -11, 32, 11, 32, 16, 27], playerMaterial);
		//var playerShapeDef:PolygonDefinition = new PolygonDefinition([16.0, -27, 11, -32, -11, -32, -16, -27, -16, 16, 16, 16], playerMaterial);
		
		var playerShapeDef:RectangleDefinition = new RectangleDefinition(28, 32, playerMaterial);
		var playerShapeDef3:CircleDefinition = new CircleDefinition(16, playerMaterial);
		var playerShapeDef2:CircleDefinition = new CircleDefinition(16, playerMaterial);
		playerShapeDef2.localPosition.y = 16;
		playerShapeDef3.localPosition.y = -16;
		var playerBodyDef:RigidBodyDefinition = new RigidBodyDefinition();
		playerBodyDef.addShape(playerShapeDef);
		playerBodyDef.addShape(playerShapeDef2);
		playerBodyDef.addShape(playerShapeDef3);
		playerBodyDef.I = Math.POSITIVE_INFINITY;
		var playerTexture:Texture2D = TextureUtils.makeTextureData(levelEditor.tileImporter.bitmapDataArray[9]);
		levelEditor.scene.initTexture(playerTexture);
		var playerSpriteDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(playerTexture);
		playerSpriteDef.registrationPoint.x = TileSettings.TILE_SIZE;
		playerSpriteDef.registrationPoint.y = TileSettings.TILE_SIZE;
		levelEditor.scene.initSpriteDefinition(playerSpriteDef);
		playerDef = new DynamicEntityDefinition(playerBodyDef, playerSpriteDef);
	}
	
	override public function stateOn():Void
	{
		game.paused = false;
		createGameData();
		levelEditor.addChild(screen);
		screen.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
		levelEditor.canvas.graphics.clear();
		game.attach(this);
	}
	
	override public function stateOff():Void
	{
		
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		game.detach(this);
		screen.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		screen.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		screen.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		screen.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		game.paused = true;
		removeGameData();
		levelEditor.scene.physicsEngine = new PhysicsEngine();
		levelEditor.scene.physicsEngine.addWorldForce(game.gravity);
		levelEditor.canvas.update();
		levelEditor.removeChild(screen);
		if(!levelEditor.contains(levelEditor.minimapContainer))
			levelEditor.addChild(levelEditor.minimapContainer);
	}
	
	public function onMouseOver(e:MouseEvent):Void
	{
		screen.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		screen.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
		screen.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		screen.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		levelEditor.addChild(playerSprite);
	}
	
	public function onMouseOut(e:MouseEvent):Void
	{
		screen.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
		screen.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		screen.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		screen.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		levelEditor.removeChild(playerSprite);
		
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		screen.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		screen.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		screen.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		playerDef.position.x = e.localX + levelEditor.canvas.offsetX;
		playerDef.position.y = e.localY + levelEditor.canvas.offsetY;
		game.addPlayer(playerDef, levelEditor.currentLayer);
		levelEditor.removeChild(playerSprite);
		if (levelEditor.contains(levelEditor.minimapContainer))
			levelEditor.removeChild(levelEditor.minimapContainer);
	}
	
	public function onMouseMove(e:MouseEvent):Void
	{
		playerSprite.x = e.localX - 32;
		playerSprite.y = e.localY - 32;
	}
	
	public function onEnterFrame(e:Event):Void
	{
		game.step();
	}
	
	public function createGameData():Void
	{
		var groundBodyDef:RigidBodyDefinition = new RigidBodyDefinition();
		var staticGroundMaterial:Material = new Material(0, 0, 0);
		var p:Array<Float>;
		for (i in 0...levelEditor.polygonPointArray.length)
		{
			p = levelEditor.polygonPointArray[i];
			var polygonDef:PolygonDefinition = new PolygonDefinition(p, staticGroundMaterial);
			if (levelEditor.polygonDataArray[i][0] == 1)
				polygonDef.resolutionCategory = 0x00010000;
			groundBodyDef.addShape(polygonDef);
		}
		game.setGroundBody(groundBodyDef);
	}
	
	public function removeGameData():Void
	{
		for (l in levelEditor.scene.entityLayerArray)
		{
			if (l == null)
				continue;
			for (d in l.entityArray)
				d.free();
		}
		game.groundBody.free();
		//for (b in levelEditor.scene.physicsEngine.bodyArray)
			//b.free();
	}
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		switch(type)
		{
			case GameEvent.PLAYER_DEATH:
				levelEditor.switchState(this);
		}
	}
}