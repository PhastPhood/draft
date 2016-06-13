package editor;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import draft.scene.Scene2D;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * ...
 * @author asdf
 */

class LayerSelector extends Sprite, implements IObservable
{

	public var levelEditor:LevelEditor;
	public var buttonArray:Array<LayerButton>;
	public var observerArray:Array<IObserver>;
	
	public function attach(o:IObserver):Void
	{
		observerArray.push(o);
	}
	
	public function detach(o:IObserver):Void
	{
		observerArray.remove(o);
	}
	
	public function notify(type:Int, data:Dynamic = null):Void
	{
		for (o in observerArray)
		{
			o.update(type, this, data);
		}
	}
	
	public function new(e:LevelEditor) 
	{
		super();
		observerArray = new Array<IObserver>();
		levelEditor = e;
		//var b:LayerButton;
		buttonArray = new Array<LayerButton>();
		for (i in 0...Scene2D.MAX_LAYER_COUNT)
		{
			if (e.scene.tileLayerArray[i] == null)
				continue;
			//trace(i);
			var lolb:LayerButton = new LayerButton(i);
			lolb.y = (Scene2D.MAX_LAYER_COUNT - i - 1) * 15;
			addChild(lolb);
			if (i == e.currentLayer)
			{
				//trace(e.currentLayer);
				lolb.drawSelected();
			}
			buttonArray.push(lolb);
			lolb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		
		
	}
	
	public function reset():Void
	{
		for (button in buttonArray)
		{
			removeChild(button);
			button = null;
		}
		untyped buttonArray.length = 0;
		
		var layerCount:Int = 0;
		for (i in 0...Scene2D.MAX_LAYER_COUNT)
		{
			if (levelEditor.scene.tileLayerArray[i] != null)
				layerCount++;
		}
		
		for (i in 0...Scene2D.MAX_LAYER_COUNT)
		{
			if (levelEditor.scene.tileLayerArray[i] == null)
				continue;
			//trace(i);
			var lolb:LayerButton = new LayerButton(i);
			lolb.y = (layerCount - i - 1) * 15;
			addChild(lolb);
			if (i == levelEditor.currentLayer)
			{
				//trace(e.currentLayer);
				lolb.drawSelected();
			}
			buttonArray.push(lolb);
			lolb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
	}
	
	public function onMouseDown(e:MouseEvent):Void
	{
		var t:LayerButton = cast(e.target, LayerButton);
		if (e.localX < 15)
		{
			t.layerVisible = !t.layerVisible;
			//trace(t.id);
			levelEditor.scene.tileLayerArray[t.id].visible = t.layerVisible;
			if (t.layerVisible)
				t.drawVisible();
			else
				t.drawInvisible();
			levelEditor.canvas.update();
		}else
		{
			for (button in buttonArray)
				button.drawUnselected();
			t.drawSelected();
			levelEditor.currentLayer = t.id;
			notify(EditorEvent.LAYER_CHANGE);
		}
		
	}
	
}
