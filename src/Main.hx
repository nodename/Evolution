package ;

import com.nodename.evolution.ImageSaver;
#if flash
import flash.Lib;
import flash.display.Bitmap;
import flash.display.Sprite;
#else
import nme.Lib;
import nme.display.Bitmap;
import nme.display.Sprite;
#end

/**
 * ...
 * @author Alan Shaw
 */

using Evolution;
class Main extends Sprite
{
	public static function main()
	{
	#if flash
		new Main();
	#else
		Lib.create(function() { new Main(); }, 500,300,5,0xccccff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
	#end
	}
	
	public function new() 
	{
		super();
		Lib.current.addChild(this);	
		evolve();
	}
		
	private function evolve():Void
	{
		//#if flash
		//haxe.Log.trace = function(s: String, ?pi: haxe.PosInfos)
		//{
		// untyped __global__["trace"](s);
		//};
		//#end
		
		var evolution = new Evolution();
		var imageX:Float = 0;
		for (image in evolution.images)
		{
			var bitmap:Bitmap = new Bitmap(image);
			bitmap.x = imageX;
			bitmap.y = #if flash 100 #else 0 #end;
			imageX += Evolution.WIDTH + 5;
			addChild(bitmap);
			var lispExpression:String = evolution.generator(image);
			trace(lispExpression);
			
			ImageSaver.savePNG(image, "EvolutionImage.png", lispExpression);
			ImageSaver.loadPNG("EvolutionImage.png");
		}
	}
}