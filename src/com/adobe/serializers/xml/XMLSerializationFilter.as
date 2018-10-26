package com.adobe.serializers.xml
{
	COMPILE::SWF { 
		import flash.utils.getQualifiedClassName;
	}
		
	COMPILE::JS {
		import org.apache.royale.reflection.getQualifiedClassName;
	}	
	
	import com.adobe.serializers.BaseSerializationFilter;
	import com.adobe.serializers.utility.TypeUtility;
	
	import mx.rpc.http.AbstractOperation;
	
	public class XMLSerializationFilter extends BaseSerializationFilter
	{
		
		private static var XPATH:String = "xPath";
		
		
		public function XMLSerializationFilter()
		{
			super();
		}
		
		override public function deserializeResult(operation:AbstractOperation, result:Object) : Object
		{
			var isCollection:Boolean = false;
			var qualifiedName:String = null;
			var isPrimitive:Boolean = false;
			var clazz:Class = null;
			var voClass:Class = null;
			if(operation.resultElementType != null)
			{
				clazz = operation.resultElementType;
				isCollection = true;
			}
			else if(operation.resultType != null)
			{
				clazz = operation.resultType;
			}
			qualifiedName = getQualifiedClassName(clazz);
			if(qualifiedName != null && qualifiedName != "" && qualifiedName != "null")
			{
				//isPrimitive = TypeUtility.isPrimitive(qualifiedName);
				if(!isPrimitive)
				{
					voClass = clazz;
				}
			}
			var xpath:String = null;
			if(operation.properties != null && operation.properties.hasOwnProperty(XPATH))
			{
				xpath = operation.properties[XPATH];
			}
			var decoder:XMLDecoder = new XMLDecoder();
			return decoder.decode(new XML(result),voClass,xpath,operation.makeObjectsBindable,isCollection);
		}
	}
}
