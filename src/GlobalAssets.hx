package ;
import flash.display.BitmapData;

/**
 * ...
 * @author asdf
 */

class GlobalAssets 
{

	public var kanyeGraphics:Map<String, BitmapData>;
	public function new() 
	{
		kanyeGraphics = new Map<String, BitmapData>();
		kanyeGraphics.set("legsRunning", new KanyeLegsRunning());
		kanyeGraphics.set("face", new KanyeFace());
		kanyeGraphics.set("body", new KanyeBody());
		kanyeGraphics.set("legsSlidingFront", new KanyeLegsSlidingFront());
		kanyeGraphics.set("legsSlidingBack", new KanyeLegsSlidingBack());
		kanyeGraphics.set("legsStandingFront", new KanyeLegsStandingFront());
		kanyeGraphics.set("legsStandingBack", new KanyeLegsStandingBack());
		kanyeGraphics.set("armRunning", new KanyeArmRunning());
		kanyeGraphics.set("armSliding", new KanyeArmSliding());
		kanyeGraphics.set("armStill", new KanyeArmStill());
		kanyeGraphics.set("boomboxFront", new KanyeBoomboxFront());
		kanyeGraphics.set("boomboxBack", new KanyeBoomboxBack());
		kanyeGraphics.set("torsoFlap", new KanyeTorsoAnimation());
		kanyeGraphics.set("standing", new KanyeStanding());
		kanyeGraphics.set("running", new KanyeRunning());
		kanyeGraphics.set("jumping", new KanyeJumping());
	}
	
}

class KanyeLegsRunning extends BitmapData {public function new(){super(0,0);}}
//class KanyeArmRunning1 extends BitmapData {public function new(){super(0,0);}}
class KanyeFace extends BitmapData {public function new(){super(0,0);}}
class KanyeBody extends BitmapData {public function new(){super(0,0);}}
class KanyeLegsSlidingFront extends BitmapData {public function new(){super(0,0);}}
class KanyeLegsSlidingBack extends BitmapData {public function new(){super(0,0);}}
class KanyeLegsStandingBack extends BitmapData {public function new(){super(0,0);}}
class KanyeLegsStandingFront extends BitmapData { public function new() { super(0, 0); }}
class KanyeArmRunning extends BitmapData { public function new() { super(0, 0); }}
class KanyeArmSliding extends BitmapData { public function new() { super(0, 0); }}
class KanyeArmStill extends BitmapData { public function new() { super(0, 0); }}
class KanyeBoomboxBack extends BitmapData { public function new() { super(0, 0); }}
class KanyeBoomboxFront extends BitmapData { public function new() { super(0, 0); }}
class KanyeTorsoAnimation extends BitmapData { public function new() { super(0, 0); }}
class KanyeStanding extends BitmapData { public function new() { super(0, 0); }}
class KanyeRunning extends BitmapData { public function new() { super(0, 0); }}
class KanyeJumping extends BitmapData { public function new() { super(0, 0); }}
