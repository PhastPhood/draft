package draft.graphics;
import flash.errors.Error;

/**
 * ...
 * @author asdf
 */

class MolehillAnimatedSpriteDefinition extends MolehillSpriteDefinition 
{
	
	public var frameWidth:Float;
	public var frameHeight:Float;
	
	public var frameCountH:Int;
	public var frameCountV:Int;
	
	public var frameCount:Int;
	
	public function new(texture:Texture2D, fWidth:Float, fHeight:Float, fCountH:Int, fCountV:Int = 1, ?fCount:Int) 
	{
		super(texture);
		width = fWidth;
		height = fHeight;
		frameWidth = fWidth;
		frameHeight = fHeight;
		frameCountH = fCountH;
		frameCountV = fCountV;
		
		if (fCount == 0)
			frameCount = fCountH * fCountV;
		else if (fCount > fCountH * fCountV)
			throw new Error("impossible frameCount");
		else
			frameCount = fCount;
			
		spriteType = MolehillSprite.ANIMATED_SPRITE;
	}
	
	public override function clone():MolehillSpriteDefinition
	{
		var ret:MolehillAnimatedSpriteDefinition = new MolehillAnimatedSpriteDefinition(texture, frameWidth, frameHeight, frameCountH, frameCountV, frameCount);
		ret.position = position.clone();
		ret.localPosition = localPosition.clone();
		ret.registrationPoint = registrationPoint.clone();
		ret.width = width;
		ret.height = height;
		ret.rotation = rotation;
		return ret;
	}
}