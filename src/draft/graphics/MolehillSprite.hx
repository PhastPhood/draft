package draft.graphics;
import draft.math.Vector2D;
import draft.utils.graphics.TextureUtils;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.errors.Error;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Vector;

/**
 * ...
 * @author 
 */

class MolehillSprite 
{
	public static inline var NORMAL_SPRITE:Int = 0;
	public static inline var ANIMATED_SPRITE:Int = 1;
	
	//only used for entities
	public var localRotation:Float;
	public var localPosition:Vector2D;
	
	public var position:Vector2D;
	public var registrationPoint:Vector2D;
	public var rotation:Float;
	public var width:Float;
	public var height:Float;
	
	public var scaleX:Float;
	public var scaleY:Float;
	
	public var textureData:Texture2D;
	
	public var vertexBuffer:VertexBuffer3D;
	public var renderMatrix:Matrix3D;
	
	public var spriteType:Int;
	
	public var next:MolehillSprite;
	public var prev:MolehillSprite;
	
	public var shaderData:Array<Float>;
	
	public function new(data:MolehillSpriteDefinition) 
	{
		position = data.position.clone();
		rotation = data.rotation;
		registrationPoint = data.registrationPoint.clone();
		textureData = data.texture;
		width = data.width;
		height = data.height;
		
		scaleX = 1;
		scaleY = 1;
		
		renderMatrix = new Matrix3D();
		
		localPosition = data.localPosition.clone();
		localRotation = data.localRotation;
		
		spriteType = NORMAL_SPRITE;
		
		shaderData = null;
	}
	
	public function updateVertexBuffer():Void
	{
		if (textureData.texture == null || vertexBuffer == null)
			throw new Error("Must initialize texture and vertex buffer before updating vertex buffer");
		
		/*var vdx:Array<Float> = [ 0.0, -1.0,  0.0,  0.0,
								 0.0,  0.0,  0.0,  0.0,
								 1.0,  0.0,  0.0,  0.0,
								 1.0, -1.0,  0.0,  0.0];//*/
								 
		var x1:Float = -(registrationPoint.x - textureData.uvRect.x * textureData.width) / (textureData.uvRect.width * textureData.width);
		var y1:Float = -(registrationPoint.y - textureData.uvRect.y * textureData.height) / (textureData.uvRect.height * textureData.height);
		var x2:Float = x1 + 1;
		var y2:Float = y1 + 1;
		
		var uvx1:Float = textureData.uvRect.x;
		var uvx2:Float = textureData.uvRect.x + textureData.uvRect.width;
		var uvy1:Float = textureData.uvRect.y;
		var uvy2:Float = textureData.uvRect.y + textureData.uvRect.height;
		
		
		var vdx:Array<Float> = [ x1, -y2, uvx1, uvy2,
								 x1, -y1, uvx1, uvy1,
								 x2, -y1, uvx2, uvy1,
								 x2, -y2, uvx2, uvy2];
		
		vertexBuffer.uploadFromVector(Vector.ofArray(vdx), 0, 4);
	}
	
	public function init(context:Context3D):Void
	{
		if(vertexBuffer == null)
			vertexBuffer = context.createVertexBuffer(4, 4);
		if (textureData.texture == null)
			textureData.init(context);
	}
	
	public static function getSpriteClass(t:Int):Class<Dynamic>
	{
		if (t == ANIMATED_SPRITE)
			return MolehillAnimatedSprite;
		return MolehillSprite;
	}
	
	public static function getSpriteDefinitionClass(t:Int):Class<Dynamic>
	{
		if (t == ANIMATED_SPRITE)
			return MolehillAnimatedSpriteDefinition;
		return MolehillSpriteDefinition;
	}
	
	public function update():Void
	{
		renderMatrix.identity();
		renderMatrix.appendScale(width, height, 1);
		renderMatrix.appendRotation( -rotation, Vector3D.Z_AXIS);
		renderMatrix.appendScale(scaleX, scaleY, 1);
		renderMatrix.appendTranslation(position.x, -position.y, 0);
		//trace(position.toString());
	}
	
	public function free():Void
	{
		registrationPoint = null;
		localPosition = null;
		position = null;
		textureData = null;
		vertexBuffer = null;
		renderMatrix = null;
		next = null;
		prev = null;
	}
}