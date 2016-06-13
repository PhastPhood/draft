package draft.physics.collisions.broadphase.strategies;
import draft.math.AABB2D;
import draft.physics.collisions.broadphase.CollisionShapeProxy;
import draft.physics.collisions.broadphase.PairManager;
import draft.physics.collisions.broadphase.strategies.spatialhash.SpatialHashBucket;
import draft.physics.collisions.shapes.CollisionShape;
import draft.physics.dynamics.contacts.ContactManager;

/**
 * ...
 * @author ...
 */

class SpatialHash implements IBroadPhase
{

	public static inline var GRID_BITS:Int = 6;
	public static inline var GRID_SIZE:Int = 1 << GRID_BITS;
	
	public static var HASH_MULTIPLIER_X:Int = 1640531513;
	
	public static var HASH_MULTIPLIER_Y:Int = Std.int(2654435789);
	
	public static inline var BUCKET_BITS:Int = 10;
	public static inline var BUCKET_COUNT:Int = 2 << BUCKET_BITS;
	
	public var dynamicBucketArray:Array<SpatialHashBucket>;
	public var staticBucketArray:Array<SpatialHashBucket>;
	
	public var staticProxyList:CollisionShapeProxy;
	public var dynamicProxyList:CollisionShapeProxy;
	
	public var proxyArray:Array<CollisionShapeProxy>;
	public var proxyArrayID:Int;
	
	public var contactManager:ContactManager;
	public var pairManager:PairManager;
	
	public function new() 
	{
		dynamicBucketArray = new Array<SpatialHashBucket>();
		staticBucketArray = new Array<SpatialHashBucket>();
		
		for (i in 0...BUCKET_COUNT)
		{
			dynamicBucketArray[i] = new SpatialHashBucket();
			staticBucketArray[i] = new SpatialHashBucket();
		}
		
		proxyArray = new Array<CollisionShapeProxy>();
		
		pairManager = new PairManager();
		pairManager.broadPhase = this;
		proxyArrayID = 0;
	}
	
	public inline function hash(x:Int, y:Int):Int
	{
		var index:Int = (x * HASH_MULTIPLIER_X + y * HASH_MULTIPLIER_Y) & (BUCKET_COUNT-1);
		return index >= 0 ? index : index + BUCKET_COUNT;
	}
	
	public inline function clearTimeStamps():Void
	{
		for (proxy in proxyArray)
		{
			proxy.timeStamp = 0;
		}
	}
	
	public function setContactManager(manager:ContactManager):Void
	{
		contactManager = manager;
		pairManager.pairCallback = manager;
	}
	
	public function commit():Void
	{
		var walker:CollisionShapeProxy = dynamicProxyList;
		var timeStamp:Int = 1;
		//trace(GRID_SIZE);
		
		while (walker != null)
		{
			
			var aabb:AABB2D = walker.shape.AABB;
			var minIndexX:Int = Std.int(aabb.min.x) >> GRID_BITS;
			var minIndexY:Int = Std.int(aabb.min.y) >> GRID_BITS;
			var maxIndexX:Int = (Std.int(aabb.max.x) >> GRID_BITS) + 1;
			var maxIndexY:Int = (Std.int(aabb.max.y) >> GRID_BITS) + 1;
			
			//trace(minIndexX + ", " + minIndexY + ", " + maxIndexX + ", " + maxIndexY);
			
			for (i in minIndexX...maxIndexX)
			{
				for (j in minIndexY...maxIndexY)
				{
					var index:Int = hash(i, j);
					var bucket:SpatialHashBucket = dynamicBucketArray[index];
					var proxy2:CollisionShapeProxy;
					var aabb2:AABB2D;
					
					if (bucket.proxyCount != 0)
					{
						for (k in 0...bucket.proxyCount)
						{
							proxy2 = bucket.proxyArray[k];
							if (walker.shape.body == proxy2.shape.body)
							{
								continue;
							}
							
							if (proxy2.timeStamp == timeStamp)
							{
								continue;
							}
							
							proxy2.timeStamp = timeStamp;
							aabb2 = proxy2.shape.AABB;
							
							if (aabb.max.x > aabb2.min.x &&
							aabb.min.x < aabb2.max.x &&
							aabb.max.y > aabb2.min.y &&
							aabb.min.y < aabb2.max.y)
							{
								pairManager.addOrUpdatePair(walker.id, proxy2.id);
							}
						}
						
					}
					bucket.proxyArray[bucket.proxyCount] = walker;
					bucket.proxyCount++;
					
					bucket = staticBucketArray[index];
					//trace(bucket.proxyCount);
					if (bucket.proxyCount == 0)
						continue;
					for (k in 0...bucket.proxyCount)
					{
						proxy2 = bucket.proxyArray[k];
						if (walker.shape.body == proxy2.shape.body)
						{
							continue;
						}
						
						if (proxy2.timeStamp == timeStamp)
						{
							//trace("ASDFASDF");
							continue;
						}
						
						proxy2.timeStamp = timeStamp;
						aabb2 = proxy2.shape.AABB;
						
						if (aabb.max.x > aabb2.min.x &&
						aabb.min.x < aabb2.max.x &&
						aabb.max.y > aabb2.min.y &&
						aabb.min.y < aabb2.max.y)
						{
							pairManager.addOrUpdatePair(walker.id, proxy2.id);
							//trace(aabb.toString + ", " + aabb2.toString);
						}
					}
				}
			}			
			timeStamp++;
			walker = walker.next;
		}
		
		for (bucket in dynamicBucketArray)
		{
			bucket.proxyCount = 0;
		}
		
		pairManager.processUnupdatedPairs();
		clearTimeStamps();
	}
	
	public function createProxy(shape:CollisionShape):Int
	{
		var proxy:CollisionShapeProxy = new CollisionShapeProxy();
		proxy.shape = shape;
		var proxyId:Int = proxyArrayID;
		proxyArray.push(proxy);
		proxyArrayID++;
		proxy.id = proxyId;
		shape.proxyID = proxyId;
		if (shape.body.isStatic)
		{
			if (staticProxyList == null)
			{
				staticProxyList = proxy;
			}else
			{
				proxy.next = staticProxyList;
				staticProxyList.prev = proxy;
				staticProxyList = proxy;
			}
			
			var aabb:AABB2D = shape.AABB;
			var minIndexX:Int = Std.int(aabb.min.x) >> GRID_BITS;
			var minIndexY:Int = Std.int(aabb.min.y) >> GRID_BITS;
			var maxIndexX:Int = (Std.int(aabb.max.x) >> GRID_BITS) + 1;
			var maxIndexY:Int = (Std.int(aabb.max.y) >> GRID_BITS) + 1;
			
			for (i in minIndexX...maxIndexX)
			{
				for (j in minIndexY...maxIndexY)
				{
					var index:Int = hash(i, j);
					staticBucketArray[index].proxyCount++;
					staticBucketArray[index].proxyArray.push(proxy);
				}
			}
						
		}else
		{
			if (dynamicProxyList == null)
			{
				dynamicProxyList = proxy;
			}else
			{
				proxy.next = dynamicProxyList;
				dynamicProxyList.prev = proxy;
				dynamicProxyList = proxy;
			}
		}
		
		return proxyId;
	}
	
	public function removeProxy(id:Int):Void
	{
		var p0:CollisionShapeProxy = getProxy(id);
		
		if (p0 == null)
			return;
		if (p0.id == CollisionShapeProxy.NULL_PROXY)
			return;
		
		var aabb:AABB2D = p0.shape.AABB;
		var aabb2:AABB2D;
		
		var minIndexX:Int = Std.int(aabb.min.x) >> GRID_BITS;
		var minIndexY:Int = Std.int(aabb.min.y) >> GRID_BITS;
		var maxIndexX:Int = (Std.int(aabb.max.x) >> GRID_BITS) + 1;
		var maxIndexY:Int = (Std.int(aabb.max.y) >> GRID_BITS) + 1;
		
		var bucketArray:Array<SpatialHashBucket> = dynamicBucketArray;
		if (p0.shape.body.isStatic)
		{
			bucketArray = staticBucketArray;
			
			for (b in bucketArray)
			{
				if (b == null)
					continue;
				if (b.proxyArray.remove(p0))
					b.proxyCount--;
			}
		}else
		{
			for (b in bucketArray)
			{
				if (b == null)
					continue;
				while (b.proxyArray.remove(p0))
				{
					continue;
				}
			}			
		}
		
		for (p1 in proxyArray)
		{
			if (p0 == p1)
				continue;
			if (p1.id == CollisionShapeProxy.NULL_PROXY)
				continue;
			aabb2 = p1.shape.AABB;
			//trace(p1.shape);
			//trace(p1.shape.localPosition == null);
			if (aabb.max.x > aabb2.min.x &&
			aabb.min.x < aabb2.max.x &&
			aabb.max.y > aabb2.min.y &&
			aabb.min.y < aabb2.max.y)
			{
				if (pairManager.removePair(id, p1.id))
					p1.overlapCount--;
			}
		}
		
		proxyArray.remove(p0);
		if (p0.next != null)
			p0.next.prev = p0.prev;
		if (p0.prev != null)
			p0.prev.next = p0.next;
		if (staticProxyList == p0)
			staticProxyList = p0.next;
		if (dynamicProxyList == p0)
			dynamicProxyList = p0.next;
		p0.shape = null;
		p0 = null;
	}
	
	public function getProxy(proxyId:Int):CollisionShapeProxy
	{
		if (proxyId == CollisionShapeProxy.NULL_PROXY)
			return null;
		for (p in proxyArray)
		{
			if (p.id == proxyId)
				return p;
		}
		return null;
	}
}