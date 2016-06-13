package editor.state;
import editor.LevelEditor;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * ...
 * @author asdf
 */

class ToggleState extends RemoveState
{

	public function new(e:LevelEditor) 
	{
		super(e);
	}
	
	override public function onMouseDown(e:MouseEvent):Void
	{
		var s:Sprite = polygonSpriteArray[0];
		for (i in 0...polygonSpriteArray.length)
		{
			s = polygonSpriteArray[i];
			if (e.target != s)
				continue;
			levelEditor.polygonDataArray[i][0]++;
			if (levelEditor.polygonDataArray[i][0] > 1)
				levelEditor.polygonDataArray[i][0] -= 2;
			drawPolygons();
			break;
		}
	}
	
}