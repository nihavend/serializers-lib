package com.adobe.serializers.json
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
	
	public class JSONSerializationFilter extends BaseSerializationFilter
	{
		
		
		public function JSONSerializationFilter()
		{
			super();
		}
		
		override public function deserializeResult(operation:AbstractOperation, result:Object) : Object
		{
			var qualifiedName:String = null;
			var isPrimitive:Boolean = false;
			var clazz:Class = null;
			var voClass:Class = null;
			if(operation.resultElementType != null)
			{
				clazz = operation.resultElementType;
			}
			else if(operation.resultType != null)
			{
				clazz = operation.resultType;
			}
			qualifiedName = getQualifiedClassName(clazz);
			if(qualifiedName != null && qualifiedName != "" && qualifiedName != "null")
			{
				isPrimitive = TypeUtility.isPrimitive(qualifiedName);
				if(!isPrimitive)
				{
					voClass = clazz;
				}
			}
			var decoder:JSONDecoder = new JSONDecoder();
			return decoder.decode(result as String,voClass,operation.makeObjectsBindable);
		}
	}
}
