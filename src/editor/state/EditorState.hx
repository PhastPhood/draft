package editor.state;

/**
 * ...
 * @author asdf
 */

class EditorState 
{

	public static inline var NO_STATE:Int = 0;
	public static inline var PLACE_STATE:Int = 1;
	public static inline var ERASE_STATE:Int = 2;
	public static inline var TEST_STATE:Int = 3;
	public static inline var EDIT_STATE:Int = 4;
	public static inline var REMOVE_STATE:Int = 5;
	public static inline var TOGGLE_STATE:Int = 6;
	
	public var levelEditor:LevelEditor;
	public function new(e:editor.LevelEditor) 
	{
		levelEditor = e;
	}
	
	public function stateOn():Void
	{
		
	}
	
	public function stateOff():Void
	{
		
	}
	
}