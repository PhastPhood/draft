package draft.graphics;
import draft.utils.graphics.TextureUtils;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.geom.Rectangle;

/**
 * ...
 * @author Jeff Gao
 */

class Texture2D 
{

	public var uvRect:Rectangle;
	public var image:BitmapData;
	public var width:Int;
	public var height:Int;
	public var texture:Texture;
	
	public function new(image:BitmapData, uvRect:Rectangle) 
	{
		this.image = image;
		this.uvRect = uvRect;
	}
	
	public function init(context:Context3D):Void
	{
		width = TextureUtils.nextPowerOfTwo(image.width);
		height = TextureUtils.nextPowerOfTwo(image.height);
		texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromBitmapData(image);
	}
	
}