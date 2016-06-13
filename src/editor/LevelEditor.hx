package editor;
import draft.game.Player;
import draft.graphics.MolehillSpriteDefinition;
import draft.graphics.Texture2D;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.physics.collisions.shapes.definitions.CircleDefinition;
import draft.physics.dynamics.Material;
import draft.physics.dynamics.RigidBodyDefinition;
import draft.scene.entity.DynamicEntityDefinition;
import draft.scene.entity.DynamicEntityMap;
import draft.scene.Scene2D;
import draft.scene.scrolling.TileMap;
import draft.scene.scrolling.TileSettings;
import draft.scene.scrolling.TileSheet;
import draft.scene.ui.ComponentSkin;
import draft.utils.graphics.TextureUtils;
import editor.collisioneditor.CollisionSheet;
import editor.state.EditorState;
import editor.state.EditState;
import editor.state.EraseState;
import editor.state.PlaceState;
import editor.state.RemoveState;
import editor.state.TestState;
import editor.state.ToggleState;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLLoader;

/**
 * ...
 * @author asdf
 */

class LevelEditor extends Sprite, implements IObserver
{

	public var tileSheets:Array<TileSheet>;
	public var collisionSheets:Array<CollisionSheet>;
	public var bitmaps:Array<BitmapData>;
	public var dimensions:Array<Array<Int>>;
	
	public var selector:TileSelector;
	public var tileImporter:TileImporter;
	public var scene:Scene2D;
	
	public var canvas:TileCanvas;
	public var minimap:Minimap;
	public var minimapContainer:WindowContainer;
	public var currentState:EditorState;
	public var noState:EditorState;
	public var placementState:PlaceState;
	public var eraseState:EraseState;
	public var removeState:RemoveState;
	public var toggleState:ToggleState;
	public var testState:TestState;
	public var editState:EditState;
	
	public var polygonPointArray:Array<Array<Float>>;
	public var polygonDataArray:Array<Array<Float>>;
	
	public var currentLayer:Int;
	
	public var saveButton:Sprite;
	public var layerSelector:LayerSelector;
	public var layerContainer:WindowContainer;
	
	public var toolbox:Toolbox;
	public var toolboxContainer:WindowContainer;
	
	public var fileReference:FileReference;
	
	public var player:Player;
	
	public function new() 
	{
		super();
		
		scene = new Scene2D(640, 480, 1 / 60);
		
		Lib.current.stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, init, false, 0, true);
		
	}
	
	public function init(e:Event):Void
	{
		currentLayer = 3;
		polygonPointArray = new Array<Array<Float>>();
		polygonDataArray = new Array<Array<Float>>();
		tileImporter = new TileImporter();
		var skin:ComponentSkin = new ComponentSkin(tileImporter.bitmapDataArray[10], [new Rectangle(0, 0, 15, 15),
			new Rectangle(15, 0, 3, 15),
			new Rectangle(18, 0, 4, 15),
			new Rectangle(22, 0, 3, 15),
			new Rectangle(25, 0, 15, 15),
			new Rectangle(40, 0, 2, 15)]);
		
		
		fileReference = new FileReference();
		selector = new TileSelector(640, 160, skin);
		selector.y = 480;
		tileSheets = new Array<TileSheet>();
		collisionSheets = new Array<CollisionSheet>();
		addTileSheet(tileImporter.bitmapDataArray[8], tileImporter.bitmapDataArray[11], 32, 32);
		selector.setTileSheet(tileSheets[0]);
		selector.attach(this);
		//addChild(new Bitmap(selector.tileSheet.batchTexture.image));
		//addChild(selector);
		
		canvas = new TileCanvas(scene);
		addChild(canvas);
		
		placementState = new PlaceState(this);
		eraseState = new EraseState(this);
		currentState = placementState;
		currentState.stateOn();
		noState = new EditorState(this);
		testState = new TestState(this);
		editState = new EditState(this);
		toggleState = new ToggleState(this);
		removeState = new RemoveState(this);
		
		var map1:TileMap = new TileMap(20, 15);
		
		
		scene.setTileLayer(map1, tileSheets[0], 3);
		var map2:TileMap = new TileMap(20, 15);
		
		
		scene.setTileLayer(map2, tileSheets[0], 2);
		var map3:TileMap = new TileMap(20, 15);
		
		
		scene.setTileLayer(map3, tileSheets[0], 4);
		
		minimap = new Minimap(this);
		minimapContainer = new WindowContainer(minimap, "MINIMAP");
		addChild(minimapContainer);
		minimapContainer.x = 641;
		minimapContainer.y = 0;
		
		layerSelector = new LayerSelector(this);
		layerContainer = new WindowContainer(layerSelector, "LAYERS");
		addChild(layerContainer);
		layerContainer.x = 641;
		layerContainer.y = minimapContainer.y + minimapContainer.height;
		
		toolbox = new Toolbox();
		toolboxContainer = new WindowContainer(toolbox, "TOOLBOX");
		addChild(toolboxContainer);
		toolboxContainer.x = 641;
		toolboxContainer.y = layerContainer.y + layerContainer.height;
		toolbox.attach(this);
		
		var playerMaterial:Material = new Material(1, 0, 0);
		var playerCircleDef:CircleDefinition = new CircleDefinition(TileSettings.TILE_SIZE, playerMaterial);
		var playerBodyDef:RigidBodyDefinition = new RigidBodyDefinition();
		playerBodyDef.addShape(playerCircleDef);
		playerBodyDef.I = Math.POSITIVE_INFINITY;
		var playerTexture:Texture2D = TextureUtils.makeTextureData(tileImporter.bitmapDataArray[9]);
		scene.initTexture(playerTexture);
		var playerSpriteDef:MolehillSpriteDefinition = new MolehillSpriteDefinition(playerTexture);
		playerSpriteDef.registrationPoint.x = TileSettings.TILE_SIZE;
		playerSpriteDef.registrationPoint.y = TileSettings.TILE_SIZE;
		scene.initSpriteDefinition(playerSpriteDef);
		var playerDef:DynamicEntityDefinition = new DynamicEntityDefinition(playerBodyDef, playerSpriteDef);
		
		var entityLayer:DynamicEntityMap;
	}
	
	public function showOpenDialog():Void
	{
		var fileTypes:FileFilter = new FileFilter("Maps (*.txt)", "*.txt");
		fileReference.browse([fileTypes]);
		fileReference.addEventListener(Event.SELECT, onFileSelect, false, 0, true);
	}
	
	public function onFileSelect(e:Event):Void
	{
		fileReference.removeEventListener(Event.SELECT, onFileSelect);
		fileReference.addEventListener(Event.COMPLETE, parseFile, false, 0, true);
		fileReference.load();
	}
	
	public function parseFile(e:Event):Void
	{
		fileReference.removeEventListener(Event.COMPLETE, parseFile);
		var txt:String = fileReference.data.readMultiByte(fileReference.data.bytesAvailable, "utf-8");
		//trace(txt);
		var collisionStart:Int = txt.indexOf("<collision>");
		var collisionEnd:Int = txt.indexOf("</collision>");
		var tileStart:Int = txt.indexOf("<tiles>");
		var tileEnd:Int = txt.indexOf("</tiles>");
		var index:Int = tileStart;
		var index2:Int = tileStart;
		var index3:Int = tileStart;
		var index4:Int = tileStart;
		
		var index5:Int = tileStart;
		var index6:Int = tileStart;
		
		var data:Array<Array<Array<Int>>> = new Array<Array<Array<Int>>>();
		
		for (i in 0...Scene2D.MAX_LAYER_COUNT)
		{
			index = txt.indexOf("[[", index + 1);
			index3 = index;
			if (index == -1)
			{
				break;
			}
			
			data[i] = new Array<Array<Int>>();
			index2 = txt.indexOf("]]", index);
			for (j in index...index2)
			{
				index3 = txt.indexOf("[", index3 + 1);
				if (index3 > index2 || index3 == -1)
					break;
				index4 = txt.indexOf("]", index3 + 1);
				data[i][j - index] = new Array<Int>();
				index5 = index3;
				for (k in index3...index4)
				{
					index6 = txt.indexOf(",", index5 + 1);
					if (index6 > index4 || index6 == -1)
					{
						data[i][j - index].push(Std.parseInt(txt.substr(index5 + 1, index4 - index5 - 1)));
						break;
					}
					//trace(txt.substr(index5 + 1, index6 - index5 - 1) + ", " + index4 + ", " + index6);
					data[i][j - index].push(Std.parseInt(txt.substr(index5 + 1, index6 - index5 - 1)));
					index5 = index6;
				}
			}
		}
		/*
		var traceStr:String = "";
		for (i in 0...data.length)
		{
			traceStr += "[";
			trace("ASDF");
			for (j in 0...data[i].length)
			{
				traceStr += "[" + data[i][j].toString() + "], \n";
			}
			traceStr += "] \n";
		}
		trace(traceStr);
		//*/
		
		var map:TileMap;
		for (i in 0...scene.tileLayerArray.length)
		{
			scene.tileLayerArray[i] = null;
		}
		for (i in 0...data.length)
		{
			map = new TileMap(data[i][0].length, data[i].length);
			map.data = data[i];
			scene.setTileLayer(map, tileSheets[0], i);
		}
		currentLayer = 0;
		//layerSelector = new LayerSelector(this);
		layerSelector.reset();
		minimap.resizeSprites();
		scene.render();
		
		//*
		index = collisionStart;
		for (i in 0...polygonPointArray.length)
		{
			untyped polygonPointArray[i].length = 0;
		}
		untyped polygonPointArray.length = 0;
		
		var index00:Int = index;
		var index01:Int = index2;
		var index02:Int = index3;
		var index03:Int = index4;
		
		for (i in collisionStart...collisionEnd)
		{
			index = txt.indexOf("[", index + 1);
			if (index > collisionEnd || index == -1)
				break;
			index2 = txt.indexOf("]", index + 1);
			polygonPointArray[i - collisionStart] = new Array<Float>();
			index3 = index;
			for (k in index...index2)
			{
				index4 = txt.indexOf(",", index3 + 1);
				if (index4 > index2 || index4 == -1)
				{
					polygonPointArray[i - collisionStart].push(Std.parseFloat(txt.substr(index3 + 1, index2 - index3 - 1)));
					break;
				}
				//trace(txt.substr(index5 + 1, index6 - index5 - 1) + ", " + index4 + ", " + index6);
				polygonPointArray[i - collisionStart].push(Std.parseInt(txt.substr(index3 + 1, index4 - index3 - 1)));
				index3 = index4;
			}
			
			index00 = txt.indexOf("<", index00 + 1);
			if (index00 > collisionEnd || index00 == -1)
				break;
			index01 = txt.indexOf(">", index00 + 1);
			polygonDataArray[i - collisionStart] = new Array<Float>();
			index02 = index00;
			for (k in index00...index01)
			{
				index03 = txt.indexOf(",", index02 + 1);
				if (index03 > index2 || index03 == -1)
				{
					polygonDataArray[i - collisionStart].push(Std.parseFloat(txt.substr(index02 + 1, index01 - index02 - 1)));
					break;
				}
				//trace(txt.substr(index5 + 1, index6 - index5 - 1) + ", " + index4 + ", " + index6);
				polygonDataArray[i - collisionStart].push(Std.parseInt(txt.substr(index02 + 1, index03 - index02 - 1)));
				index02 = index03;
			}
		}//*/
		
		switchState(currentState);
		
	}
	
	public function save():Void
	{
		var map:String = "<tiles>\r\n";
		for (layer in scene.tileLayerArray)
		{
			if (layer == null)
				continue;
			map += "[";
			for (i in 0...layer.tileMap.height)
			{
				map += "[";
				map += layer.tileMap.data[i].toString();
				map += "]";
				if (i != layer.tileMap.height - 1)
					map += ",\r\n";
			}
			map += "]\r\n\r\n";
		}
		
		map += "</tiles>\r\n\r\n<collision>\r\n";
		for (i in 0...polygonPointArray.length)
		{
			if (polygonPointArray[i] == null)
				continue;
			map += "[";
			map += polygonPointArray[i].toString();
			map += "] <";
			map += polygonDataArray[i].toString();
			map += ">";
			map += "\r\n";
		}
		map += "</collision>";
		fileReference.save(map, "Tilemap.txt");
	}
	
	public function addTileSheet(bitmap:BitmapData, cBitmap:BitmapData, tileWidth:Int, tileHeight:Int):Void
	{
		var tilesH:Int = Std.int(bitmap.width / tileWidth);
		var tilesV:Int = Std.int(bitmap.height / tileHeight);
		//trace(tilesH + ", " + tilesV);
		var ar:Array<Array<Int>> = new Array<Array<Int>>();
		for (i in 0...tilesH)
		{
			for (j in 0...tilesV)
			{
				ar.push([i * tileWidth, j * tileHeight, tileWidth, tileHeight]);
			}
		}
		
		var ts:TileSheet = new TileSheet(bitmap, ar, scene.stagehand.context);
		tileSheets.push(ts);
		
		var cs:CollisionSheet = new CollisionSheet(cBitmap, ts);
		collisionSheets.push(cs);
	}
	
	public function switchState(s:EditorState):Void
	{
		currentState.stateOff();
		s.stateOn();
		currentState = s;
	}
	
	
	public function update(type:Int, source:IObservable, data:Dynamic):Void
	{
		switch(type)
		{
			case EditorEvent.TOOL_CHANGE:
				if (data == null)
					return;
				var state:Int = cast(data, Int);
				switch(state)
				{
					case EditorState.NO_STATE:
						switchState(noState);
					case EditorState.PLACE_STATE:
						switchState(placementState);
					case EditorState.ERASE_STATE:
						switchState(eraseState);
					case EditorState.TEST_STATE:
						switchState(testState);
					case EditorState.EDIT_STATE:
						switchState(editState);
					case EditorState.REMOVE_STATE:
						switchState(removeState);
					case EditorState.TOGGLE_STATE:
						switchState(toggleState);
				}
			case EditorEvent.SAVE:
				save();
			case EditorEvent.OPEN:
				showOpenDialog();
		}
	}
	
}