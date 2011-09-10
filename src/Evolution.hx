package ;

import com.nodename.evolution.EvolutionLib;
import com.nodename.evolution.ImageMemory;
import com.nodename.lisp.Cons;
import com.nodename.lisp.FunctionSpec;
import com.nodename.lisp.LispInterpreter;
import com.nodename.lisp.SExpressionParser;
import com.nodename.lisp.StdLib;
import de.polygonal.ds.HashTable;
import de.polygonal.ds.Hashable;

#if flash
import flash.display.BitmapData;
import com.nodename.evolution.lib.UnaryF;
#else
import nme.display.BitmapData;
#end

/**
 * ...
 * @author Alan Shaw
 */

using com.nodename.lisp.Cons;
using com.nodename.lisp.SExpressionParser;
class Evolution 
{
	public static inline var WIDTH:Int = 200;
	public static inline var HEIGHT:Int = 200;
	public static inline var PIXELS:Int = WIDTH * HEIGHT;
	
	private static inline var MAX_DEPTH:Int = 3;
	
	private static inline var NOT:Bool = true;
	
	private static inline var evolutionLib:Hash<FunctionSpec> = EvolutionLib.ENV;
	
	public var images:Array<BitmapData>;
	
	private var _expressionTable:HashTable<Hashable, String>;

	public function new() 
	{
		#if flash
		ImageMemory.createStorage();
		#end
		
		var lispExpressions:Array<String> = [
			//"(X)",
			//"(Y)",
			//"(* .5 X)",
			//"(* 2 Y)",
			//"(abs X)",
			//"(and X Y)",
			//"(and (* 1.5 Y) (abs X))",
			//"(bw-noise 123 3 .8)",
			//"(xor X Y)",
			//"(sin (xor X Y))",
			//"(xor (cos X) Y)",
			//"(blur 8 4 1 X)",
			//"(log (inverse (sin (xor (bw-noise 123 3 .8) (cos (bw-noise 123 6 .25))))))",
			
			// ***ATTENTION: This expression will crash the CPP build of the program***
			//"(xor (bw-noise 380 3 0.7205267495) (blur 1024 1 16 (* 2 X)))"
			
			//"(min (cos (abs (- (bw-noise 583 5 0.9926928449887782) (min (sin Y) (cos X))))) (bw-noise 195 4 0.6664412152953446))",
			//"(* Y)"
			//makeExpression(),
			//makeExpression(),
			//makeExpression(),
			//"(xor (- X Y) (bw-noise 338 2 0.7551622059))"
			makeExpression()
			//"(mod X Y)"
		];
		
		images = new Array<BitmapData>();
		
		_expressionTable = new HashTable<Hashable, String>(16);
		
		for (lispExpression in lispExpressions)
		{
			//trace(lispExpression);
			var exp:Cons = lispExpression.parse();
			
			var evaluation:Dynamic = LispInterpreter.eval(exp, evolutionLib);
			
			var image:BitmapData = cast(evaluation, BitmapData);
			images.push(image);
			_expressionTable.set(cast(image, Hashable), lispExpression);
		}
		
	}
	
	public function generator(image:BitmapData):String
	{
		return _expressionTable.get(cast(image, Hashable));
	}
	
	static inline function makeExpression():String
	{
		var expr:String = generateExpression();
		if (expr.charAt(0) != "(")
		{
			expr = "(" + expr + ")";
		}
		return makeNice(expr);
	}
	
	static inline function makeNice(expr:String):String
	{
		var collapseMultipleSpaces:EReg = ~/ +/g;
		expr = collapseMultipleSpaces.replace(expr, " ");
		
		var removeSpacesBeforeCloseParens:EReg = ~/ +\)/g;
		expr = removeSpacesBeforeCloseParens.replace(expr, ")");
		
		var removeSpacesAfterOpenParens:EReg = ~/\( +/g;
		expr = removeSpacesAfterOpenParens.replace(expr, "(");
		
		var ensureSpaceBeforeEachOpenParenExceptFirst:EReg = ~/([^^ ])\(/g;
		expr = ensureSpaceBeforeEachOpenParenExceptFirst.replace(expr, "$1 (");
		
		return expr;
	}
	
	static function generateExpression(depth=0):String
	{
		// FULL method
		//var functionName = if (depth == MAX_DEPTH) choose0aryFunctionName() else choose0aryFunctionName(NOT);
		
		// GROW method
		var functionName = if (depth == MAX_DEPTH) choose0aryFunctionName() else EvolutionLib.randomFunctionName();
		
		var expression:String = "";
		var parametersString:String = generateParameters(functionName);
		var inputImageCount:Int = EvolutionLib.arity(functionName);
		if (inputImageCount > 0 || parametersString.length > 0)
		{
			expression += "( ";
		}
		else
		{
			expression += " ";
		}
		expression += functionName;
		
		expression += parametersString;
		expression += " ";
		
		for (i in 0...inputImageCount)
		{
			expression += generateExpression(depth + 1);
		}
		expression += " ";
		if (inputImageCount > 0 || parametersString.length > 0)
		{
			expression += ")";
		}
		return expression;
	}
	
	static inline function choose0aryFunctionName(?not:Bool):String
	{
		var theFunctions:Array<String> = EvolutionLib.functions(not, 0);
		return theFunctions[Math.floor(Math.random() * theFunctions.length)];
	}
	
	static inline function generateParameters(functionName:String):String
	{
		var argsString:String = "";
		var parameterSpecs:Array<Dynamic> = EvolutionLib.parameterSpec(functionName);
		for (parameterSpec in parameterSpecs)
		{
			argsString += " " + StdLib.random(parameterSpec);
		}
		return argsString;
	}
	
}