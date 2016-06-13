package draft.graphics;
import draft.math.Vector2D;
import flash.display3D.Context3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.Vector;

/**
 * ...
 * @author asdf
 */

class MolehillSpriteDefinition 
{
	//position - taken from global position of registration point
	public var position:Vector2D;
	public var rotation:Float;
	
	public var localPosition:Vector2D;
	public var localRotation:Float;
	
	public var width:Float;
	public var height:Float;
	
	//registration point relative to texture bitmap starting uv
	public var registrationPoint:Vector2D;
	public var texture:Texture2D;
	public var vertexBuffer:VertexBuffer3D;
	public var spriteType:Int;
	
	public var next:MolehillSpriteDefinition;
	public var prev:MolehillSpriteDefinition;
	
	public function new(texture:Texture2D) 
	{
		this.texture = texture;
		
		position = new Vector2D();
		registrationPoint = new Vector2D();
		
		width = texture.image.width;
		height = texture.image.height;
		
		rotation = 0;
		
		spriteType = MolehillSprite.NORMAL_SPRITE;
		
		localPosition = new Vector2D();
		localRotation = 0;
	}
	
	public function clone():MolehillSpriteDefinition
	{
		var ret:MolehillSpriteDefinition = new MolehillSpriteDefinition(texture);
		ret.position = position.clone();
		ret.registrationPoint = registrationPoint.clone();
		ret.localPosition = localPosition.clone();
		ret.localRotation = localRotation;
		ret.width = width;
		ret.height = height;
		ret.rotation = rotation;
		return ret;
	}
	
	
}