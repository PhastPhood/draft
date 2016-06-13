package editor;
import draft.patterns.IObservable;
import draft.patterns.IObserver;
import editor.state.EditorState;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * ...
 * @author asdf
 */

class Toolbox extends Sprite, implements IObservable
{
	public var placeButton:ToolboxButton;
	public var eraseButton:ToolboxButton;
	public var collisionButton:ToolboxButton;
	public var removeButton:ToolboxButton;
	public var toggleButton:ToolboxButton;
	public var stateTools:Array<ToolboxButton>;
	public var states:Array<Int>;
	
	public var saveButton:ToolboxButton;
	public var openButton:ToolboxButton;
	public var testButton:ToolboxButton;
	
	public var observerArray:Array<IObserver>;
	
	public function new() 
	{
		super();
		observerArray = new Array<IObserver>();
		placeButton = new ToolboxButton("PLACE");
		eraseButton = new ToolboxButton("ERASE");
		eraseButton.y = 18;
		collisionButton = new ToolboxButton("EDIT DATA");
		collisionButton.y = 36;
		removeButton = new ToolboxButton("REMOVE DATA");
		removeButton.y = 54;
		toggleButton = new ToolboxButton("TOGGLE DATA");
		toggleButton.y = 72;
		testButton = new ToolboxButton("TEST");
		testButton.y = 90;
		placeButton.drawSelected();
		saveButton = new ToolboxButton("SAVE");
		saveButton.y = 126;
		openButton = new ToolboxButton("OPEN");
		openButton.y = 144;
		addChild(placeButton);
		addChild(eraseButton);
		addChild(collisionButton);
		addChild(removeButton);
		addChild(toggleButton);
		addChild(openButton);
		addChild(saveButton);
		addChild(testButton);
		
		stateTools = new Array<ToolboxButton>();
		states = new Array<Int>();
		stateTools.push(placeButton);
		states.push(EditorState.PLACE_STATE);
		stateTools.push(eraseButton);
		states.push(EditorState.ERASE_STATE);
		stateTools.push(collisionButton);
		states.push(EditorState.EDIT_STATE);
		stateTools.push(removeButton);
		states.push(EditorState.REMOVE_STATE);
		stateTools.push(toggleButton);
		states.push(EditorState.TOGGLE_STATE);
		stateTools.push(testButton);
		states.push(EditorState.TEST_STATE);
		
		for (button in stateTools)
		{
			button.addEventListener(MouseEvent.MOUSE_DOWN, stateMouseDown, false, 0, true);
		}
		
		saveButton.addEventListener(MouseEvent.MOUSE_DOWN, saveMouseDown, false, 0, true);
		openButton.addEventListener(MouseEvent.MOUSE_DOWN, openMouseDown, false, 0, true);
	}
	
	public function stateMouseDown(e:MouseEvent):Void
	{
		for (i in 0...stateTools.length)
		{
			stateTools[i].drawUnselected();
			if (e.target == stateTools[i] || e.target == stateTools[i].text)
			{
				notify(EditorEvent.TOOL_CHANGE, states[i]);
				stateTools[i].drawSelected();
			}
		}
	}
	
	public function saveMouseDown(e:MouseEvent):Void
	{
		notify(EditorEvent.SAVE);
	}
	
	public function openMouseDown(e:MouseEvent):Void
	{
		notify(EditorEvent.OPEN);
	}
	
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
}