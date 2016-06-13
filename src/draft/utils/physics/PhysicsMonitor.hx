/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils.physics;
import draft.physics.PhysicsEngine;
import draft.utils.StatMonitor;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.xml.XML;
import flash.xml.XMLList;

class PhysicsMonitor extends StatMonitor
{
	public var contactCount:Int;
	public var bodyCount:Int;
	public var shapeCount:Int;
	
	public var world:PhysicsEngine;
	private var rectangle:Sprite;
	
	private var text:TextField;
	
	public function new(w:PhysicsEngine) 
	{
		super();
		h = 43;
		world = w;
	}
	
	public override function init():Void
	{
		rectangle = new Sprite();
		rectangle.graphics.beginFill(0xFFFFFF, 1);
		rectangle.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		rectangle.graphics.drawRect(0, 0, w, h);
		addChild(rectangle);
		
		text = new TextField();
		text.width = w - 10;
		text.height = h - 2;
		text.selectable = false;
		text.mouseEnabled = false;
		text.condenseWhite = true;
		text.multiline = true;
		text.x = 2;
		text.y = 2;
		addChild(text);
		addEventListener(Event.ENTER_FRAME, update, false, 0, true);

	}
	
	public override function update(e:Event):Void
	{
		
		text.htmlText = "<FONT FACE = '_sans' SIZE = '9' COLOR = '#00FFFF'>BODIES: " + world.bodyCount + "<br>" + 
		"SHAPES: " + world.shapeArray.length + "<br>" + 
		"CONTACTS: " + world.contactManager.activeContactCount + "</FONT>";
		

	}
	
}