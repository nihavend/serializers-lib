package com.adobe.serializers.json
{
	
	COMPILE::SWF {
		import flash.utils.getDefinitionByName;
	}
		
	COMPILE::JS {
		import org.apache.royale.reflection.getDefinitionByName;
	}
		
	import com.adobe.serializers.utility.TypeUtility;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectProxy;
	
	// [ResourceBundle("serializer")]
	public class JSONDecoder
	{
		
		private static const number:String = "(?:-?\\b(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?\\b)";
		
		private static const oneChar:String = "(?:[^\\0-\\x08\\x0a-\\x1f\"\\\\]" + "|\\\\(?:[\"/\\\\bfnrt]|u[0-9A-Fa-f]{4}))";
		
		private static const string:String = "(?:\"" + oneChar + "*\")";
		
		private static const jsonToken:RegExp = new RegExp("(?:false|true|null|[\\{\\}\\[\\]]" + "|" + number + "|" + string + ")","g");
		
		private static const escapeSequence:RegExp = /\\(?:([^u])|u(.{4}))/g;
		
		private static const escapes:Object = {
			"\"":"\"",
			"/":"/",
			"\\":"\\",
			"b":"\b",
			"f":"\f",
			"n":"\n",
			"r":"\r",
			"t":"\t"
		};
		
		
		private const EMPTY_STRING:String = new String("");
		
		private const SLASH:String = "\\";
		
		private var tokens:Array;
		
		private var token:String;
		
		private var index:int;
		
		private var value:Object;
		
		private var makeObjectsBindable:Boolean;
		
		public function JSONDecoder()
		{
			super();
		}
		
		private function unescapeOne(s:String, ch:String, hex:String, index:int, str:String) : String
		{
			return Boolean(ch)?escapes[ch]:String.fromCharCode(parseInt(hex,16));
		}
		
		public function decode(jsonString:String, clazz:Class = null, makeObjectsBindable:Boolean = true) : *
		{
			this.tokens = jsonString.match(jsonToken);
			this.makeObjectsBindable = makeObjectsBindable;
			this.index = 0;
			this.nextToken();
			this.value = this.parseValue(clazz);
			TypeUtility.clear();
			return this.value;
		}
		
		private function nextToken() : String
		{
			return this.token = this.tokens[this.index++];
		}
		
		private function parseValue(clazz:Class = null) : Object
		{
			var str:String = null;
			var message:String = ResourceManager.getInstance().getString("serializer","parseError");
			if(this.token == null)
			{
				throw new Error(message);
			}
			switch(this.token.charCodeAt(0))
			{
				case TokenType.LEFT_BRACE:
					return this.parseObject(clazz);
				case TokenType.LEFT_BRACKET:
					if(this.makeObjectsBindable && (this.index == 1 || !clazz))
					{
						return new ArrayCollection(this.parseArray(clazz));
					}
					return this.parseArray(clazz);
				case TokenType.STRING:
					str = this.token.substring(1,this.token.length - 1);
					if(str.indexOf(this.SLASH) !== -1)
					{
						str = str.replace(escapeSequence,this.unescapeOne);
					}
					return str;
				case TokenType.TRUE:
					return true;
				case TokenType.FALSE:
					return false;
				case TokenType.NULL:
					return null;
				case 45:
				case 43:
				case 48:
				case 49:
				case 50:
				case 51:
				case 52:
				case 53:
				case 54:
				case 55:
				case 56:
				case 57:
					return this.parseNumber();
				default:
					throw new Error(message);
			}
		}
		
		private function parseObject(clazz:Class = null) : Object
		{
			var o:Object = null;
			var key:String = null;
			var subClazz:Class = null;
			var isDate:Boolean = false;
			var isArray:Boolean = false;
			var isArrayCollection:Boolean = false;
			var assignValue:Boolean = false;
			var type:String = null;
			var isPrimitive:Boolean = false;
			var value:Object = null;
			var message:String = null;
			if(clazz != null)
			{
				o = new clazz();
			}
			else
			{
				o = new Object();
				if(this.makeObjectsBindable)
				{
					o = new ObjectProxy(o);
				}
			}
			this.nextToken();
			if(this.token.charCodeAt(0) == TokenType.RIGHT_BRACE)
			{
				return o;
			}
			while(true)
			{
				if(this.token.charCodeAt(0) == TokenType.STRING)
				{
					key = this.token.substring(1,this.token.length - 1);
					subClazz = clazz;
					isDate = false;
					isArray = false;
					isArrayCollection = false;
					if(clazz != null)
					{
						key = TypeUtility.getUnderScoreName(clazz,o,key);
						type = TypeUtility.getType(clazz,key);
						isPrimitive = TypeUtility.isPrimitive(type);
						isDate = TypeUtility.isDate(type);
						isArray = TypeUtility.isArray(type);
						isArrayCollection = TypeUtility.isArrayCollection(type);
						if(isArray || isArrayCollection)
						{
							isArray = true;
							subClazz = TypeUtility.getArrayType(clazz,key);
						}
						else if(type != null && type.length > 0 && !isPrimitive)
						{
							subClazz = getDefinitionByName(type) as Class;
						}
					}
					this.nextToken();
					assignValue = false;
					if(clazz != null)
					{
						if(o.hasOwnProperty(key))
						{
							assignValue = true;
						}
					}
					else
					{
						assignValue = true;
					}
					if(assignValue)
					{
						value = this.parseValue(subClazz);
						if(isDate)
						{
							o[key] = TypeUtility.getDate(value);
						}
						else if(isArray)
						{
							if(isArrayCollection)
							{
								if(subClazz == null && value is ArrayCollection)
								{
									o[key] = value as ArrayCollection;
								}
								else
								{
									o[key] = new ArrayCollection(value as Array);
								}
							}
							else if(subClazz == null && value as ArrayCollection)
							{
								o[key] = (value as ArrayCollection).source;
							}
							else
							{
								o[key] = value as Array;
							}
						}
						else if(value is Array && this.makeObjectsBindable)
						{
							o[key] = new ArrayCollection(value as Array);
						}
						else
						{
							o[key] = value;
						}
					}
					else
					{
						this.parseValue(subClazz);
					}
					this.nextToken();
					if(this.token.charCodeAt(0) == TokenType.RIGHT_BRACE)
					{
						return o;
					}
					continue;
				}
				message = ResourceManager.getInstance().getString("serializer","stringExpected",[this.token]);
				throw new Error(message);
			}
			return null;
		}
		
		private function parseArray(clazz:Class = null) : Array
		{
			var a:Array = new Array();
			this.nextToken();
			if(this.token.charCodeAt(0) == TokenType.RIGHT_BRACKET)
			{
				return a;
			}
			while(true)
			{
				a.push(this.parseValue(clazz));
				this.nextToken();
				if(this.token.charCodeAt(0) == TokenType.RIGHT_BRACKET)
				{
					return a;
				}
			}
			return null;
		}
		
		private function parseNumber() : Number
		{
			var message:String = null;
			var num:Number = Number(this.token);
			if(isFinite(num) && !isNaN(num))
			{
				return num;
			}
			message = ResourceManager.getInstance().getString("serializer","numberExpected",[this.token]);
			throw new Error(message);
		}
	}
}

class TokenType
{
	
	public static const LEFT_BRACE:int = 123;
	
	public static const RIGHT_BRACE:int = 125;
	
	public static const LEFT_BRACKET:int = 91;
	
	public static const RIGHT_BRACKET:int = 93;
	
	public static const TRUE:int = 116;
	
	public static const FALSE:int = 102;
	
	public static const NULL:int = 110;
	
	public static const STRING:int = 34;
	
	
	function TokenType()
	{
		super();
	}
}
