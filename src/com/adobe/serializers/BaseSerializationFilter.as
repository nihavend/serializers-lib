package com.adobe.serializers
{
	
	COMPILE::JS {
		import mx.messaging.errors.ArgumentError;
	}
	
	import mx.core.mx_internal;
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;
	
	public class BaseSerializationFilter extends SerializationFilter
	{
		
		private static var URL_PARAMS:String = "urlParams";
		
		private static var URL_PARAM_NAMES:String = "urlParamNames";
		
		private static var PARAM_START:String = "{";
		
		private static var PARAM_END:String = "}";
		
		
		public function BaseSerializationFilter()
		{
			super();
		}
		
		override public function serializeParameters(operation:AbstractOperation, params:Array) : Object
		{
			var prop:String = null;
			var xml:Object = null;
			var urlParamNames:Array = [];
			var urlParams:Object = null;
			if(operation.properties != null && operation.properties.hasOwnProperty(URL_PARAM_NAMES) && operation.properties[URL_PARAM_NAMES] != null)
			{
				urlParams = {};
				urlParamNames = operation.properties[URL_PARAM_NAMES] as Array;
				for each(prop in urlParamNames)
				{
					urlParams[prop] = null;
				}
			}
			if(params.length - urlParamNames.length == 1 && operation.contentType == AbstractOperation.mx_internal::CONTENT_TYPE_XML)
			{
				xml = params[params.length - 1];
				this.populateURLParams(operation,urlParamNames,params,urlParams);
				return xml;
			}
			var argNames:Array = operation.argumentNames;
			if(params == null || params.length == 0)
			{
				return params;
			}
			if(argNames == null || params.length != argNames.length)
			{
				throw new ArgumentError("HTTPMultiService operation called with " + (argNames == null?0:argNames.length) + " argumentNames and " + params.length + " number of parameters.  When argumentNames is specified, it must match the number of arguments passed to the invocation");
			}
			return this.populateURLParams(operation,argNames,params,urlParams);
		}
		
		override public function serializeURL(operation:AbstractOperation, obj:Object, url:String) : String
		{
			var urlParams:Object = null;
			var prop:* = null;
			var param:String = null;
			var pattern:RegExp = null;
			if(url != null && operation.properties != null && operation.properties.hasOwnProperty(URL_PARAMS) && operation.properties[URL_PARAMS] != null)
			{
				urlParams = operation.properties[URL_PARAMS];
				for(prop in urlParams)
				{
					param = PARAM_START + prop + PARAM_END;
					if(url.indexOf(param) != -1)
					{
						pattern = new RegExp(param,"//g");
						url = url.replace(pattern,urlParams[prop]);
					}
				}
			}
			return url;
		}
		
		private function populateURLParams(operation:AbstractOperation, argNames:Array, params:Array, urlParams:Object) : Object
		{
			var obj:Object = {};
			for(var i:int = 0; i < argNames.length; i++)
			{
				if(urlParams != null && urlParams.hasOwnProperty(argNames[i]))
				{
					urlParams[argNames[i]] = params[i];
				}
				else
				{
					obj[argNames[i]] = params[i];
				}
			}
			if(urlParams != null)
			{
				if(operation.properties == null)
				{
					operation.properties = {};
				}
				operation.properties[URL_PARAMS] = urlParams;
			}
			return obj;
		}
	}
}
