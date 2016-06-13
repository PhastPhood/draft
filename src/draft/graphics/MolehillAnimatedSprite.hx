package draft.graphics;
import flash.display3D.Context3D;
import flash.errors.Error;
import flash.geom.Rectangle;
import flash.Vector;

/**
 * ...
 * @author asdf
 */

class MolehillAnimatedSprite extends MolehillSprite
{
	public var currentFrame:Int;
	public var frameCount:Int;
	
	//for grid layout
	public var frameCountH:Int;
	public var frameCountV:Int;
	
	public var frameWidth:Float;
	public var frameHeight:Float;
	
	private var vertexX1:Float;
	private var vertexY1:Float;
	private var vertexX2:Float;
	private var vertexY2:Float;
	
	private var uvWidth:Float;
	private var uvHeight:Float;
	
	public var borderX:Float;
	public var borderY:Float;
	
	public function new(data:MolehillAnimatedSpriteDefinition) 
	{
		currentFrame = 0;
		
		frameWidth = data.frameWidth;
		frameHeight = data.frameHeight;
		
		frameCountH = data.frameCountH;
		frameCountV = data.frameCountV;
		
		frameCount = data.frameCount;
		
		if (frameCount > frameCountH * frameCountV)
			throw new Error("impossible frameCount");
		
		spriteType = MolehillSprite.ANIMATED_SPRITE;
		
		super(data);
			
		vertexX1 = -registrationPoint.x / frameWidth;
		vertexY1 = -registrationPoint.y / frameHeight;
		vertexX2 = vertexX1 + 1;
		vertexY2 = vertexY1 + 1;
	}
	
	public override function init(context:Context3D):Void
	{
		super.init(context);
		
		uvWidth = frameWidth / textureData.width;
		uvHeight = frameHeight / textureData.height;
		
		borderX = 0.5 / textureData.width;
		borderY = 0.5 / textureData.height;
	}
	
	public override function updateVertexBuffer():Void
	{
		if (textureData.texture == null || vertexBuffer == null)
			throw new Error("Must initialize texture and vertex buffer before updating vertex buffer");
		
		/*var vdx:Array<Float> = [ 0.0, -1.0,  0.0,  0.0,
								 0.0,  0.0,  0.0,  0.0,
								 1.0,  0.0,  0.0,  0.0,
								 1.0, -1.0,  0.0,  0.0];//*/
		if (currentFrame >= frameCount)
			currentFrame %= frameCount;
		
		var framex:Int = currentFrame % frameCountH;
		var framey:Int = Std.int(currentFrame / frameCountH);
		
		var uvx1:Float = textureData.uvRect.x + framex * uvWidth + borderX;
		var uvx2:Float = uvx1 + uvWidth - 2 * borderX;
		var uvy1:Float = textureData.uvRect.y + framey * uvHeight + borderY;
		var uvy2:Float = uvy1 + uvHeight - 2 * borderY;
		
		var vdx:Array<Float> = [ vertexX1, -vertexY2, uvx1, uvy2,
								 vertexX1, -vertexY1, uvx1, uvy1,
								 vertexX2, -vertexY1, uvx2, uvy1,
								 vertexX2, -vertexY2, uvx2, uvy2];
		
		vertexBuffer.uploadFromVector(Vector.ofArray(vdx), 0, 4);
	}
}