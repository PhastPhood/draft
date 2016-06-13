/**
 * ...
 * @author Jeffrey Gao
 */

package draft.utils;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;

class MonitorUtil extends Sprite
{
	private var dragBar:Sprite;
	private var closeButton:Sprite;

	private var container:Sprite;
	private var closedContainer:Sprite;
	private var openContainer:Sprite;
	
	private var monitors:Array<StatMonitor>;
	private var boundsRect:Rectangle;
	
	public var w:Int;
	private var isOpen:Bool;
	private var bottom:Int;
	
	public function new() 
	{
		w = 80;
		
		boundsRect = new Rectangle(0, 0, Lib.current.stage.stageWidth - w, Lib.current.stage.stageHeight - bottom);
		monitors = new Array<StatMonitor>();
		isOpen = true;
		super();
		init();
	}
	
	public function init():Void
	{
		closedContainer = new Sprite();
		
		openContainer = new Sprite();
		addChild(openContainer);
		
		dragBar = new Sprite();
		dragBar.graphics.beginFill(0x000000, 10);
		dragBar.graphics.drawRect(0, 0, w, 15);
		dragBar.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER, 0);
		dragBar.graphics.endFill();
		dragBar.graphics.moveTo(0, 15);
		dragBar.graphics.lineTo(w, 15);
		dragBar.graphics.lineStyle(1, 0xDCDCDC, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		dragBar.graphics.drawRect(0, 0, w, 15);
		addChild(dragBar);
		bottom = 15;
		
		dragBar.addEventListener(MouseEvent.MOUSE_DOWN, dragMouseDown, false, 0, true);
		
		closeButton = new Sprite();
		closeButton.graphics.beginFill(0x000000, 10);
		closeButton.graphics.lineStyle(1, 0x00FFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		closeButton.graphics.drawRect(0, 0, 12, 6);
		closeButton.graphics.endFill();
		
		closeButton.graphics.lineStyle(1.2, 0x00FFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER, 2);
		closeButton.graphics.moveTo(4, 4);
		closeButton.graphics.lineTo(6, 2);
		closeButton.graphics.lineTo(8, 4);
		
		closeButton.x = w - 11 - 2 - 5;
		closeButton.y = 5;
		closeButton.addEventListener(MouseEvent.MOUSE_UP, closeMouseUp, false, 0, true);
		addChild(closeButton);
	}
	
	public function addMonitor(monitor:StatMonitor):Void
	{
		monitors.push(monitor);
		monitor.w = w;
		monitor.init();
		openContainer.addChild(monitor);
		monitor.y = bottom;
		bottom += monitor.h;
		
		
		boundsRect = new Rectangle(0, 0, Lib.current.stage.stageWidth - w, Lib.current.stage.stageHeight - bottom);
	}
	
	private function dragMouseDown(e:MouseEvent):Void
	{
		dragBar.removeEventListener(MouseEvent.MOUSE_DOWN, dragMouseDown);
		startDrag(false, boundsRect);
		dragBar.addEventListener(MouseEvent.MOUSE_UP, dragMouseUp, false, 0, true);
	}
	
	private function dragMouseUp(e:MouseEvent):Void
	{	
		dragBar.removeEventListener(MouseEvent.MOUSE_UP, dragMouseUp);
		stopDrag();	
		dragBar.addEventListener(MouseEvent.MOUSE_DOWN, dragMouseDown, false, 0, true);
	
	}
	
	private function closeMouseUp(e:MouseEvent):Void
	{
		if (isOpen)
		{
			closeButton.scaleY = -1;
			closeButton.y += 6;
			close();
		}
		else
		{
			closeButton.scaleY = 1;
			closeButton.y -= 6;
			open();
		}
		isOpen = !isOpen;
	}
	
	private function open():Void
	{
		removeChild(closedContainer);
		addChild(openContainer);
	}
	
	private function close():Void
	{
		removeChild(openContainer);
		addChild(closedContainer);
	}
	
}