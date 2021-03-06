/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.shapes;
import draft.math.RotationMatrix2D;
import draft.math.Vector2D;
import draft.physics.collisions.shapes.definitions.PolygonDefinition;
import draft.physics.dynamics.RigidBody;

class PolygonShape extends CollisionShape
{
	public var localOrientation:RotationMatrix2D;
	public var orientation:RotationMatrix2D;
	
	public var localVertexArray:Array<Vector2D>;
	public var localVertexList:Vector2D;
	public var localNormalArray:Array<Vector2D>;
	public var localNormalList:Vector2D;
	
	public var worldVertexArray:Array<Vector2D>;
	public var worldVertexList:Vector2D;
	public var worldNormalArray:Array<Vector2D>;
	public var worldNormalList:Vector2D;
	
	public var vertexCount:Int;
	
	public var localCenter:Vector2D;
	public var worldCenter:Vector2D;
	
	private var hCxMax:Int;
	private var hCxMin:Int;
	private var hCyMax:Int;
	private var hCyMin:Int;
	public function new(polygonData:PolygonDefinition, body:RigidBody) 
	{

		super(polygonData, body);
		
		shapeType = CollisionShape.POLYGON_TYPE;
		
		vertexCount = polygonData.localVertexArray.length;
		
		localOrientation = new RotationMatrix2D(polygonData.localRotation);
		localPosition = polygonData.localPosition.clone();
		orientation = new RotationMatrix2D();
		
		localVertexArray = new Array<Vector2D>();
		worldVertexArray = new Array<Vector2D>();
		localNormalArray = new Array<Vector2D>();
		worldNormalArray = new Array<Vector2D>();
		
		var v:Vector2D;
		for (i in 0...vertexCount) {
			v = polygonData.localVertexArray[i];
			localVertexArray[i] = v.clone();
			worldVertexArray[i] = new Vector2D();
			
			v = polygonData.localNormalArray[i];
			localNormalArray[i] = v.clone();
			worldNormalArray[i] = new Vector2D();
		}
		
		var i2:Int;
		var i3:Int;
		for (i in 0...vertexCount) {
			i2 = (i + 1) % vertexCount;
			i3 = i - 1;
			if (i3 < 0)
				i3 = vertexCount - 1;
			v = localVertexArray[i];
			v.next = localVertexArray[i2];
			v.prev = localVertexArray[i3];
			
			v = localNormalArray[i];
			v.next = localNormalArray[i2];
			v.prev = localNormalArray[i3];
			
			v = worldVertexArray[i];
			v.next = worldVertexArray[i2];
			v.prev = worldVertexArray[i3];
			
			v = worldNormalArray[i];
			v.next = worldNormalArray[i2];
			v.prev = worldNormalArray[i3];
			
		}
		
		localVertexList = localVertexArray[0];
		localNormalList = localNormalArray[0];
		worldVertexList = worldVertexArray[0];
		worldNormalList = worldNormalArray[0];
		
		localCenter = polygonData.center.clone();
		
		worldCenter = new Vector2D();
		
		updateWorldCoordinates();
		initAABB();
	}
	
	private function initAABB():Void
	{
		var minx:Float = Math.POSITIVE_INFINITY;
		var miny:Float = Math.POSITIVE_INFINITY;
		var maxx:Float = Math.NEGATIVE_INFINITY;
		var maxy:Float = Math.NEGATIVE_INFINITY;
		
		var i:Int = 0;
		for (vertex in worldVertexArray) {
			if (vertex.x > maxx) {
				maxx = vertex.x;
				hCxMax = i;
			}
			if (vertex.x < minx) {
				minx = vertex.x;
				hCxMin = i;
			}
			if (vertex.y > maxy) {
				maxy = vertex.y;
				hCyMax = i;
			}
			if (vertex.y < miny) {
				miny = vertex.y;
				hCyMin = i;
			}
			i++;
		}
	}
	
	override public function update():Void
	{
		updateWorldCoordinates();
		updateAABB();
	}
	
	override public function updateAABB():Void
	{
		AABB.min.x = Math.POSITIVE_INFINITY;
		AABB.min.y = Math.POSITIVE_INFINITY;
		AABB.max.x = Math.NEGATIVE_INFINITY;
		AABB.max.y = Math.NEGATIVE_INFINITY;
		for (walker in worldVertexArray){
			if (walker.x > AABB.max.x)
				AABB.max.x = walker.x;
			if (walker.x < AABB.min.x)
				AABB.min.x = walker.x;
				
			if (walker.y > AABB.max.y)
				AABB.max.y = walker.y;
			if (walker.y < AABB.min.y)
				AABB.min.y = walker.y;
		}
	}
	
	public function updateWorldCoordinates():Void
	{
		orientation.angle = (localOrientation.angle + body.getRotation()) % 6.283185307179586;
		orientation.i1j1 = localOrientation.i1j1 * body.orientation.i1j1 + localOrientation.i1j2 * body.orientation.i2j1;
		orientation.i1j2 = localOrientation.i1j1 * body.orientation.i1j2 + localOrientation.i1j2 * body.orientation.i2j2;
		orientation.i2j1 = localOrientation.i2j1 * body.orientation.i1j1 + localOrientation.i2j2 * body.orientation.i2j1;
		orientation.i2j2 = localOrientation.i2j1 * body.orientation.i1j2 + localOrientation.i2j2 * body.orientation.i2j2;
		
		var lx:Float = localPosition.x - body.localCenterOfMass.x;
		var ly:Float = localPosition.y - body.localCenterOfMass.y;
		
		position.x = body.worldCenterOfMass.x + body.orientation.i1j1 * lx + body.orientation.i1j2 * ly;
		position.y = body.worldCenterOfMass.y + body.orientation.i2j1 * lx + body.orientation.i2j2 * ly;
		
		var wIndex:Vector2D;
		
		var r11:Float = orientation.i1j1;
		var r12:Float = orientation.i1j2;
		var r21:Float = orientation.i2j1;
		var r22:Float = orientation.i2j2;
		
		for (i in 0...vertexCount) {
			wIndex = worldVertexArray[i];
			lx = localVertexArray[i].x;
			ly = localVertexArray[i].y;
			wIndex.x = lx * r11 + ly * r12 + position.x;
			wIndex.y = lx * r21 + ly * r22 + position.y;
			
			wIndex = worldNormalArray[i];
			lx = localNormalArray[i].x;
			ly = localNormalArray[i].y;
			wIndex.x = lx * r11 + ly * r12;
			wIndex.y = lx * r21 + ly * r22;
		}
		
		lx = localCenter.x;
		ly = localCenter.y;
		worldCenter.x = lx * r11 + ly * r12 + position.x;
		worldCenter.y = lx * r21 + ly * r22 + position.y;
	}
	
	override public function free():Void
	{
		for (v in worldVertexArray)
		{
			v.next = null;
			v.prev = null;
			v = null;
		}
		
		worldVertexList = null;
		
		for (v in localVertexArray)
		{
			v.next = null;
			v.prev = null;
			v = null;
		}
		
		localVertexList = null;
		
		for (v in worldNormalArray)
		{
			v.next = null;
			v.prev = null;
			v = null;
		}
		
		worldNormalList = null;
		
		for (v in localNormalArray)
		{
			v.next = null;
			v.prev = null;
			v = null;
		}
		
		localNormalList = null;
		
		localOrientation = null;
		orientation = null;
		
		localCenter = null;
		worldCenter = null;
		super.free();
	}
	
}