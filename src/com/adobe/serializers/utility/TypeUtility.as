package com.adobe.serializers.utility
{
	COMPILE::SWF { 
		import flash.utils.getDefinitionByName;
		import flash.utils.getQualifiedClassName;
		import flash.utils.Dictionary;
	}
		
	COMPILE::JS {
		import org.apache.royale.reflection.getDefinitionByName;
		import org.apache.royale.reflection.getQualifiedClassName;
		import com.adobe.serializers.utils.Dictionary;
	}
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.utils.DescribeTypeCache;
	import mx.utils.ObjectUtil;
	
	public class TypeUtility
	{
		
		private static var TYPE_INT:String = "int";
		
		private static var TYPE_STRING:String = "String";
		
		private static var TYPE_BOOLEAN:String = "Boolean";
		
		private static var TYPE_NUMBER:String = "Number";
		
		private static var TYPE_DATE:String = "Date";
		
		private static var TYPE_ARRAYCOLLECTION:String = "mx.collections::ArrayCollection";
		
		private static var TYPE_ARRAYCOLLECTION_2:String = "mx.collections.ArrayCollection";
		
		private static var TYPE_ARRAY:String = "Array";
		
		private static var propertyTypeMap:Dictionary;
		
		private static var arrayTypeMap:Dictionary;
		
		
		public function TypeUtility()
		{
			super();
		}
		
		public static function getType(clazz:Class, propertyName:String) : String
		{
			var description:XML = null;
			var typeFromCache:String = null;
			if(!propertyTypeMap)
			{
				propertyTypeMap = new Dictionary(false);
			}
			if(!propertyTypeMap[clazz])
			{
				propertyTypeMap[clazz] = new Dictionary(false);
			}
			var type:String = propertyTypeMap[clazz][propertyName];
			if(type != null)
			{
				return type;
			}
			var obj:Object = new clazz();
			var model:Object = getModel(obj);
			try
			{
				if(model != null && model.hasOwnProperty("getPropertyType"))
				{
					type = model.getPropertyType(propertyName);
				}
			}
			catch(e:Error)
			{
			}
			try
			{
				if(type == null || type.length < 1)
				{
					if(obj.hasOwnProperty("__getPropertyType"))
					{
						type = obj.__getPropertyType(propertyName);
					}
				}
			}
			catch(e:Error)
			{
			}
			var ARRAYCOLLECTION:String = "ArrayCollection";
			if(type == null || type.length < 1 || type == ARRAYCOLLECTION)
			{
				description = DescribeTypeCache.describeType(obj).typeDescription;
				typeFromCache = description..*.(name() == "variable" || name() == "accessor").(@name == propertyName).@type;
				if(type != null && type == ARRAYCOLLECTION)
				{
					if(isArrayCollection(typeFromCache))
					{
						type = typeFromCache;
					}
				}
				else
				{
					type = typeFromCache;
				}
			}
			propertyTypeMap[clazz][propertyName] = type;
			return type;
		}
		
		public static function getArrayType(clazz:Class, propertyName:String) : Class
		{
			var value:String = null;
			var obj:Object = null;
			var model:Object = null;
			var name:String = null;
			if(!arrayTypeMap)
			{
				arrayTypeMap = new Dictionary(false);
			}
			if(!arrayTypeMap[clazz])
			{
				arrayTypeMap[clazz] = new Dictionary(false);
			}
			var type:Class = arrayTypeMap[clazz][propertyName];
			if(type != null)
			{
				return type;
			}
			var classInfo:Object = ObjectUtil.getClassInfo(clazz,null,null);
			var metadataInfo:Object = classInfo["metadata"];
			if(metadataInfo.hasOwnProperty(propertyName) && metadataInfo[propertyName].hasOwnProperty("ArrayElementType"))
			{
				for each(value in metadataInfo[propertyName]["ArrayElementType"])
				{
					type = getDefinitionByName(value) as Class;
				}
			}
			else
			{
				obj = new clazz();
				model = getModel(obj);
				name = null;
				if(model != null && model.hasOwnProperty("getCollectionBase"))
				{
					name = model.getCollectionBase(propertyName);
					if(name != null && name.length > 0)
					{
						type = getDefinitionByName(name) as Class;
					}
				}
				else if(obj.hasOwnProperty("__getCollectionBase"))
				{
					name = obj.__getCollectionBase(propertyName);
					if(name != null && name.length > 0)
					{
						type = getDefinitionByName(name) as Class;
					}
				}
			}
			if(type != null)
			{
				arrayTypeMap[clazz][propertyName] = type;
			}
			return type;
		}
		
		public static function getProperties(obj:Object) : Array
		{
			var model:Object = getModel(obj);
			if(model != null && model.hasOwnProperty("getDataProperties"))
			{
				return model.getDataProperties();
			}
			if(obj.hasOwnProperty("__getDataProperties"))
			{
				return obj.__getDataProperties();
			}
			return null;
		}
		
		private static function getModel(obj:Object) : Object
		{
			var model:Object = null;
			var description:XML = null;
			var list:XMLList = null;
			if(obj.hasOwnProperty("_model"))
			{
				model = obj["_model"];
				description = DescribeTypeCache.describeType(model).typeDescription;
				list = description..implementsInterface.(@type == "com.adobe.fiber.valueobjects::IModelType");
				if(list.length() > 0)
				{
					return model;
				}
			}
			return null;
		}
		
		public static function getXPathArray(xPath:String) : Array
		{
			if(xPath == null || xPath == "" || xPath == "/")
			{
				return null;
			}
			var arr:Array = xPath.split("/");
			arr.shift();
			return arr;
		}
		
		public static function isPrimitive(type:String) : Boolean
		{
			return type == TYPE_INT || type == TYPE_STRING || type == TYPE_BOOLEAN || type == TYPE_NUMBER || type == TYPE_DATE;
		}
		
		public static function isDate(type:String) : Boolean
		{
			return type == TYPE_DATE;
		}
		
		public static function isArrayCollection(type:String) : Boolean
		{
			return type == TYPE_ARRAYCOLLECTION || type == TYPE_ARRAYCOLLECTION_2;
		}
		
		public static function isArray(type:String) : Boolean
		{
			return type == TYPE_ARRAY;
		}
		
		public static function getDate(value:Object) : Date
		{
			return new Date(Date.parse(value));
		}
		
		public static function getUnderScoreName(clazz:Class, result:Object, key:String) : String
		{
			if(clazz && !result.hasOwnProperty(key) && result.hasOwnProperty("_" + key))
			{
				return "_" + key;
			}
			return key;
		}
		
		public static function clear() : void
		{
			propertyTypeMap = null;
			arrayTypeMap = null;
		}
		
		private static function isObject(obj:Object) : Boolean
		{
			return getQualifiedClassName(obj) == "Object" || getQualifiedClassName(obj) == "mx.utils::ObjectProxy";
		}
		
		public static function convertResultHandler(result:*, operation:AbstractOperation) : *
		{
			var prop:* = null;
			if(operation.properties != null && operation.properties.hasOwnProperty("singleValueResult") && operation.properties["singleValueResult"] == true)
			{
				if(isObject(result))
				{
					for(prop in result)
					{
						result = result[prop];
					}
				}
			}
			var convertedResult:* = result;
			if(operation.resultElementType != null && !isObject(operation.resultElementType) && result != null)
			{
				if((result is ArrayCollection || result is Array) && result.length > 0 && (isObject(result[0]) || result[0] is Array))
				{
					convertedResult = convertListToStrongType(result,operation.resultElementType);
				}
			}
			else if(operation.resultType != null && !isObject(operation.resultType) && result != null && (isObject(result) || result is Array))
			{
				convertedResult = convertToStrongType(result,operation.resultType);
			}
			clear();
			if(convertedResult is Array)
			{
				convertedResult = new ArrayCollection(convertedResult as Array);
			}
			return convertedResult;
		}
		
		public static function convertCFAMFParametersHandler(args:Array) : Array
		{
			if(args != null && args.length == 1)
			{
				if(args[0] is int || args[0] is uint || args[0] is Number || args[0] is String || args[0] is Date || args[0] is Boolean)
				{
					return args;
				}
				return args.concat(null);
			}
			return args;
		}
		
		public static function emptyEventHandler(event:FaultEvent, operation:AbstractOperation) : void
		{
		}
		
		public static function convertListToStrongType(source:Object, clazz:Class, objectsVOMap:Dictionary = null) : Object
		{
			if(!(source is ArrayCollection || source is Array))
			{
				return source;
			}
			if(objectsVOMap == null)
			{
				objectsVOMap = new Dictionary();
			}
			if(objectsVOMap[source] != null)
			{
				return objectsVOMap[source];
			}
			var result:Array = [];
			for(var i:int = 0; i < source.length; i++)
			{
				if(objectsVOMap[source[i]] == null)
				{
					result[i] = convertToStrongType(source[i],clazz,objectsVOMap);
					objectsVOMap[source[i]] = result[i];
				}
				else
				{
					result[i] = objectsVOMap[source[i]];
				}
			}
			var ac:ArrayCollection = new ArrayCollection(result);
			objectsVOMap[source] = ac;
			return ac;
		}
		
		public static function convertToStrongType(source:Object, clazz:Class, objectsVOMap:Dictionary = null) : Object
		{
			var prop:* = null;
			if(clazz == null)
			{
				return source;
			}
			if(objectsVOMap == null)
			{
				objectsVOMap = new Dictionary();
			}
			if(objectsVOMap[source] != null)
			{
				return objectsVOMap[source];
			}
			if(source is clazz)
			{
				return source;
			}
			var res:Object = new clazz();
			for(prop in source)
			{
				assignProperty(source,res,prop,clazz,objectsVOMap);
			}
			objectsVOMap[source] = res;
			return res;
		}
		
		private static function assignProperty(source:Object, result:Object, property:String, clazz:Class, objectsVOMap:Dictionary) : void
		{
			var resultProperty:String = getUnderScoreName(clazz,result,property);
			var subClazz:Class = clazz;
			var type:String = TypeUtility.getType(clazz,resultProperty);
			var isPrimitive:Boolean = TypeUtility.isPrimitive(type);
			var isArray:Boolean = TypeUtility.isArray(type);
			var isArrayCollection:Boolean = TypeUtility.isArrayCollection(type);
			if(isArray || isArrayCollection)
			{
				isArray = true;
				subClazz = TypeUtility.getArrayType(clazz,resultProperty);
			}
			else if(type != null && type.length > 0 && !isPrimitive)
			{
				subClazz = getDefinitionByName(type) as Class;
			}
			if(result.hasOwnProperty(resultProperty))
			{
				if(isPrimitive || isObject(subClazz))
				{
					if(type == TYPE_NUMBER && source[property] == null)
					{
						result[resultProperty] = Number.NaN;
					}
					else
					{
						result[resultProperty] = source[property];
					}
				}
				else if(isArrayCollection || isArray)
				{
					if(source[property] == null)
					{
						result[resultProperty] = null;
						return;
					}
					if(objectsVOMap[source[property]] == null)
					{
						result[resultProperty] = convertListToStrongType(source[property],subClazz,objectsVOMap);
						objectsVOMap[source[property]] = result[resultProperty];
					}
					else
					{
						result[resultProperty] = objectsVOMap[source[property]];
					}
				}
				else
				{
					if(source[property] == null)
					{
						result[resultProperty] = null;
						return;
					}
					if(objectsVOMap[source[property]] == null)
					{
						result[resultProperty] = convertToStrongType(source[property],subClazz,objectsVOMap);
						objectsVOMap[source[property]] = result[resultProperty];
					}
					else
					{
						result[resultProperty] = objectsVOMap[source[property]];
					}
				}
			}
		}
		
		public static function convertToCollection(value:Object) : IList
		{
			if(value == null)
			{
				return null;
			}
			if(value is ArrayCollection)
			{
				return value as ArrayCollection;
			}
			if(value is Array)
			{
				return new ArrayCollection(value as Array);
			}
			return new ArrayCollection([value]);
		}
	}
}
