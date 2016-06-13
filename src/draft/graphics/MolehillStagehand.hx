package draft.graphics;
import draft.graphics.shaders.SBMultiplierShader;
import draft.graphics.shaders.IShader2D;
import draft.graphics.shaders.obnoxious.SharpenShader;
import draft.graphics.shaders.StandardShader;
import draft.math.MathApprox;
import draft.utils.graphics.TextureUtils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import haxe.Log;


/**
 * ...
 * @author 
 */

class MolehillStagehand 
{
	
	public var width:Int;
	public var height:Int;
	public var stage:Stage3D;
	public var context:Context3D;
	public var shader:IShader2D;
	
	public var rectangleIndexBuffer:IndexBuffer3D;
	private static var IDENTITY:Matrix3D = new Matrix3D();
	
	
	
	public function new(w:Int, h:Int) 
	{
		width = w;
		height = h;
		//viewMatrix.appendTranslation(-width/2, -height/2, 0);
		//viewMatrix.appendScale(1, -1, 1);
		
		stage = Lib.current.stage.stage3Ds[0];
		stage.addEventListener(Event.CONTEXT3D_CREATE, init, false, 0, true);
		stage.requestContext3D();
		
	}
	
	public function init(e:Event):Void
	{
		stage.removeEventListener(Event.CONTEXT3D_CREATE, init);
		
		context = stage.context3D;
		context.enableErrorChecking = true;
		context.configureBackBuffer(width, height, 2, true);
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		context.setDepthTest(true, Context3DCompareMode.ALWAYS);
		shader = new SBMultiplierShader(context);
		
		/*
		spriteVertexBuffer.uploadFromVector(Vector.ofArray([
				-1.0, 1.0, 0.0, 1.0,
				-1.0,-1.0, 0.0, 0.0,
				 1.0,-1.0, 1.0, 0.0,
				 1.0, 1.0, 1.0, 1.0
			]), 0, 4);//*/
			//*
			
		rectangleIndexBuffer = context.createIndexBuffer(6);
		var idx:Array<UInt> = [0, 1, 2, 0, 2, 3];
		rectangleIndexBuffer.uploadFromVector(Vector.ofArray(idx), 0, 6);
		Log.setColor(0xFF0000);
		context.clear(1, 1, 1, 0);
		context.present();
	}
	
	public function beginDraw():Void
	{
		if (context == null)
			return;
		if (context.driverInfo == "Disposed")
			return;
		context.clear(1, 1, 1, 0);
	}
	
	public function drawSprite(sprite:MolehillSprite, cameraMatrix:Matrix3D):Void
	{
		if (context == null)
			return;
		if (context.driverInfo == "Disposed")
			return;
		shader.apply(sprite.vertexBuffer, sprite.textureData.texture, sprite.renderMatrix, cameraMatrix, sprite.shaderData);
		context.drawTriangles(rectangleIndexBuffer, 0, 2);
		//trace("WTF");
	}
	
	//vertex array contains x, y, u, v triangle coordinates
	public function drawBatch(batchTexture:BatchTexture, vertexArray:Array<Float>, cameraMatrix:Matrix3D, shaderData:Dynamic = null):Void
	{
		if (context == null)
			return;
		if (context.driverInfo == "Disposed")
			return;
		var pointCount:Int = Std.int(vertexArray.length * 0.25);
		if (pointCount == 0)
			return;
		var batchVBuffer:VertexBuffer3D = context.createVertexBuffer(pointCount, 4);
		batchVBuffer.uploadFromVector(Vector.ofArray(vertexArray), 0, pointCount);
		var triCount:Int = Std.int(pointCount * 0.5);
		var indexCount:Int = triCount * 3;
		var batchIBuffer:IndexBuffer3D = context.createIndexBuffer(indexCount);
		var indexArray:Array<UInt> = new Array<UInt>();
		for (i in 0...pointCount)
		{
			var a:UInt = i * 4;
			indexArray.push(a);
			indexArray.push(a + 1);
			indexArray.push(a + 2);
			indexArray.push(a);
			indexArray.push(a + 2);
			indexArray.push(a + 3);
		}
		batchIBuffer.uploadFromVector(Vector.ofArray(indexArray), 0, indexCount);
		shader.apply(batchVBuffer, batchTexture.texture, IDENTITY, cameraMatrix, shaderData);
		context.drawTriangles(batchIBuffer, 0, triCount);

	}
	
	public function endDraw():Void
	{
		if (context == null)
			return;
		if (context.driverInfo == "Disposed")
			return;
		context.present();
	}
	
}