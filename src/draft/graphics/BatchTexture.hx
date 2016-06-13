package draft.graphics;
import draft.utils.graphics.TextureUtils;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;

/**
 * ...
 * @author asdf
 */

class BatchTexture 
{

	public var image:BitmapData;
	public var texture:Texture;
	
	public var width:Int;
	public var height:Int;
	
	public function new(image:BitmapData) 
	{
		this.image = image;
	}
	
	public function init(context:Context3D):Void
	{
		width = TextureUtils.nextPowerOfTwo(image.width);
		height = TextureUtils.nextPowerOfTwo(image.height);
		texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromBitmapData(image);
	}
	
}