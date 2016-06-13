/**
 * ...
 * @author Jeffrey Gao
 */

package draft.physics.collisions.broadphase;
import draft.physics.collisions.broadphase.strategies.IBroadPhase;
import draft.physics.dynamics.contacts.Contact;

class PairManager 
{
	
	public var broadPhase:IBroadPhase;
	public var pairCallback:IPairCallback;
	
	public var pairPoolHead:Pair;
	public var pairPoolTail:Pair;
	
	public var poolSize:Int;
	public var activePairCount:Int;
	
	public var allocationPair:Pair;
	
	public var activePairArray:Array<Pair>;
	
	public var MAX_PROXIES:Int;
	
	public function new() 
	{
		MAX_PROXIES = 1000;
		activePairArray = new Array<Pair>();
		
		var poolInitialSize:Int = 100;
		poolSize = poolInitialSize;
		pairPoolHead = new Pair();
		pairPoolTail = new Pair();
		
		pairPoolHead.next = pairPoolTail;
		pairPoolTail.prev = pairPoolHead;
		
		var p:Pair;
		
		for ( i in 0...poolInitialSize)
		{
			p = new Pair();
			p.next = pairPoolHead;
			pairPoolHead.prev = p;
			pairPoolHead = p;
			
		}
		
		pairPoolTail.next = pairPoolHead;
		pairPoolHead.prev = pairPoolTail;
		allocationPair = pairPoolHead;
	}
	
	
	public function addOrUpdatePair(proxyId1:Int, proxyId2:Int):Bool
	{
		if (proxyId1 == proxyId2)
			return false;
		
		
		var min:Int = proxyId1;
		var max:Int = proxyId2;
		
		if (min > max)
		{
			min = proxyId2;
			max = proxyId1;
		}
		//min * (2 * MAX_PROXIES - min - 3) /2 + max - 1;
		var index:Int = min * ((2 * MAX_PROXIES - min - 3)>>1) + max - 1;
		
		if (activePairArray[index] != null)
		{
			activePairArray[index].updated = true;
			return false;
		}
		
		if (activePairCount == poolSize)
		{
			var growSize:Int = 50;
			poolSize += growSize;
			
			var p1:Pair = pairPoolTail;
			var p2:Pair = pairPoolTail;
			
			var newPair:Pair;
			
			for (i in 0...growSize)
			{
				newPair = new Pair();
				p2.next = newPair;
				newPair.prev = p2;
				p2 = newPair;
			}
			
			pairPoolTail = p2;
			pairPoolTail.next = pairPoolHead;
			pairPoolHead.prev = pairPoolTail;
			
			allocationPair = p1.next;
		}
		
		var pair:Pair = allocationPair;
		allocationPair = allocationPair.next;
		
		activePairCount++;
		
		var c:Contact = pairCallback.pairAdded(broadPhase.getProxy(proxyId1).shape, broadPhase.getProxy(proxyId2).shape);
		pair.proxyId1 = proxyId1;
		pair.proxyId2 = proxyId2;
		pair.contact = c;
		pair.updated = true;
		pair.active = true;
		
		activePairArray[index] = pair;
		return true;
	}
	
	public function removePair(proxyId1:Int, proxyId2:Int):Bool
	{
		if (proxyId1 == proxyId2)
			return false;
			
		var min:Int = proxyId1;
		var max:Int = proxyId2;
		
		if (min > max)
		{
			min = proxyId2;
			max = proxyId1;
		}
		//min * (2 * MAX_PROXIES - min - 3) /2 + max - 1;
		var index:Int = min * ((2 * MAX_PROXIES - min - 3)>>1) + max - 1;
		var pair:Pair = activePairArray[index];
		
		if (pair == null)
		{
			return false;
		}
		pair.active = false;
			
		if (pair == pairPoolHead)
		{
			pairPoolHead = pairPoolHead.next;
			pairPoolTail = pair;
		}else if (pair != pairPoolTail)
		{
			var p:Pair = pair.prev;
			var n:Pair = pair.next;
			n.prev = p;
			p.next = n;
			pair.prev = pairPoolTail;
			pair.next = pairPoolHead;
			pairPoolTail.next = pair;
			pairPoolHead.prev = pair;
			pairPoolTail = pair;
		}
		if (activePairCount == poolSize)
		{
			allocationPair = pair;
		}
		
		activePairCount--;
		
		pairCallback.pairRemoved(pair.contact);
		activePairArray[index] = null;
		
		return true;
	}
	
	public function processUnupdatedPairs():Void
	{
		var walker:Pair = pairPoolHead;
		//var i:Int = 0;
		//var j:Int = activePairCount;
		var pairsToRemove:Array<Pair> = [];
		while (walker != pairPoolTail)
		{
			if (walker.active)
			{
				if (!walker.updated)
					pairsToRemove.push(walker);
				
				walker.updated = false;
			}
			walker = walker.next;
		}
		//trace(i + ", " + j + ", " + activePairCount);
		if (walker.active)
		{
			if (!walker.updated)
				pairsToRemove.push(walker);
			
			walker.updated = false;
		}
		for (pair in pairsToRemove)
		{
			removePair(pair.proxyId1, pair.proxyId2);
		}
		
	}
	
}