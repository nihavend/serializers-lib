package com.adobe.serializers.xml
{
	
	COMPILE::SWF { 
		import flash.utils.getDefinitionByName;
	}
		
	COMPILE::JS {
		import org.apache.royale.reflection.getDefinitionByName;
	}
		
	import com.adobe.serializers.utility.TypeUtility;
	import mx.collections.ArrayCollection;
	// import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ObjectProxy;
	
	public class XMLDecoder
	{
		
		
		private var makeObjectsBindable:Boolean;
		
		private var isCollection:Boolean;
		
		public function XMLDecoder()
		{
			super();
		}
		
		public function decode(xml:XML, clazz:Class = null, xPath:String = null, makeObjectsBindable:Boolean = true, isCollection:Boolean = false) : *
		{
			var children:XMLList = null;
			var i:int = 0;
			var j:int = 0;
			var result:Object = null;
			var path:String = null;
			var ns:Object = null;
			var index:int = 0;
			var newList:XMLList = null;
			var atttributeList:XMLList = null;
			var prefix:String = null;
			var temp:XML = null;
			var tempXML:XML = null;
			var nsPrefix:String = null;
			var pre:String = null;
			var qname:QName = null;
			var child:XML = null;
			this.makeObjectsBindable = makeObjectsBindable;
			this.isCollection = isCollection;
			var xPathArray:Array = null;
			if(xPath != null && xPath != "")
			{
				xPathArray = TypeUtility.getXPathArray(xPath);
			}
			var xmlList:XMLList = new XMLList(xml);
			i = 0;
			while(xmlList.length() > 0 && xPathArray && i < xPathArray.length)
			{
				path = xPathArray[i];
				ns = null;
				index = path.lastIndexOf("::");
				if(index != -1)
				{
					prefix = path.substring(0,index);
					if(prefix != null && prefix.length > 0)
					{
						temp = XML(xmlList[0]);
						ns = temp.namespace(prefix);
						if(ns == null)
						{
							children = temp.children();
							for(j = 0; j < children.length(); j++)
							{
								tempXML = children[j];
								ns = tempXML.namespace(prefix);
								if(ns != null)
								{
									break;
								}
							}
						}
					}
					else
					{
						for(j = 0; j < XML(xmlList[0]).namespaceDeclarations().length; j++)
						{
							ns = xml.namespaceDeclarations()[j];
							nsPrefix = ns.prefix;
							if(nsPrefix == "")
							{
								break;
							}
							ns = null;
						}
					}
					path = path.substr(index + 2);
				}
				else
				{
					ns = XML(xmlList[0]).namespace("");
				}
				newList = null;
				atttributeList = null;
				if(ns != null)
				{
					if(ns is Namespace)
					{
						pre = (ns as Namespace).prefix;
					}
					if(pre != null && pre.length > 0)
					{
						path = path.replace(pre + "_","");
					}
					qname = new QName(ns,path);
					newList = xmlList.elements(qname);
					if(newList.length() == 0)
					{
						children = xmlList.children();
						for(j = 0; j < children.length(); j++)
						{
							child = children[j];
							if(child.localName() == path && child.namespace().prefix == prefix)
							{
								newList = new XMLList(child);
								break;
							}
						}
					}
					if(newList.length() == 0 && i == xPathArray.length - 1)
					{
						atttributeList = this.geLeafList(xmlList,qname,clazz);
						if(atttributeList != null)
						{
							newList = atttributeList;
						}
					}
					xmlList = newList;
				}
				else
				{
					newList = xmlList.elements(path);
					if(newList.length() == 0 && i == xPathArray.length - 1)
					{
						atttributeList = this.geLeafList(xmlList,path,clazz);
						if(atttributeList != null)
						{
							newList = atttributeList;
						}
					}
					xmlList = newList;
				}
				i++;
			}
			if(isCollection)
			{
				result = [];
				for(i = 0; i < xmlList.length(); i++)
				{
					if(clazz == null && XML(xmlList[i]).hasSimpleContent() && XML(xmlList[i]).attributes().length() == 0)
					{
						// result.push(SimpleXMLDecoder.simpleType(xmlList[i].toString()));
					}
					else
					{
						result.push(this.parseXML(xmlList[i],clazz));
					}
				}
				if(makeObjectsBindable)
				{
					result = new ArrayCollection(result as Array);
				}
			}
			else if(xmlList.length() >= 1)
			{
				if(XML(xmlList[0]).hasSimpleContent() && XML(xmlList[0]).attributes().length() == 0)
				{
					// return SimpleXMLDecoder.simpleType(xmlList[0].toString());
				}
				result = this.parseXML(xmlList[0],clazz);
			}
			else
			{
				result = !!makeObjectsBindable?new ObjectProxy():{};
			}
			TypeUtility.clear();
			return result;
		}
		
		private function geLeafList(xmlList:XMLList, path:Object, clazz:Class) : XMLList
		{
			var newList:XMLList = null;
			if(!this.isCollection && clazz == null && xmlList[0].attribute(path).length() == 1)
			{
				newList = xmlList[0].attribute(path);
			}
			else if(this.isCollection && xmlList.attribute(path).length() >= 1)
			{
				newList = xmlList.attribute(path);
			}
			return newList;
		}
		
		private function parseXML(xml:XML, clazz:Class) : *
		{
			var i:int = 0;
			var localName:String = null;
			var name:String = null;
			var ns:Namespace = null;
			var valuePresent:Boolean = false;
			var child:XML = null;
			var subClazz:Class = null;
			var type:String = null;
			var key:String = null;
			var result:Object = {};
			if(clazz)
			{
				result = new clazz();
			}
			else if(this.makeObjectsBindable)
			{
				result = new ObjectProxy(result);
			}
			var textList:XMLList = xml.text();
			var value:String = "";
			for(i = 0; i < textList.length(); i++)
			{
				value = value + textList[i];
			}
			if(value != null && value.length > 0)
			{
				valuePresent = true;
				localName = xml.localName();
				// this.fillValue(result,clazz,localName,SimpleXMLDecoder.simpleType(value));
			}
			var children:XMLList = xml.elements();
			for(i = 0; i < children.length(); i++)
			{
				child = children[i];
				ns = child.namespace();
				if(ns != null && ns.prefix != null && ns.prefix != "")
				{
					name = ns.prefix + "_" + child.localName();
				}
				else
				{
					name = child.localName();
				}
				if(valuePresent && name == localName)
				{
					name = "_" + name;
				}
				else
				{
					name = TypeUtility.getUnderScoreName(clazz,result,name);
				}
				if(child.hasComplexContent() || child.attributes().length() > 0)
				{
					subClazz = clazz;
					if(clazz)
					{
						type = TypeUtility.getType(clazz,name);
						if(type == null || type == "")
						{
							continue;
						}
						if(TypeUtility.isArray(type) || TypeUtility.isArrayCollection(type))
						{
							subClazz = TypeUtility.getArrayType(clazz,name);
						}
						else
						{
							subClazz = getDefinitionByName(type) as Class;
						}
					}
					this.fillValue(result,clazz,name,this.parseXML(child,subClazz));
				}
				else
				{
					name = TypeUtility.getUnderScoreName(clazz,result,name);
					// this.fillValue(result,clazz,name,SimpleXMLDecoder.simpleType(child.toString()));
				}
			}
			var attributes:XMLList = xml.attributes();
			for(i = 0; i < attributes.length(); i++)
			{
				key = attributes[i].localName();
				key = TypeUtility.getUnderScoreName(clazz,result,key);
				// this.fillValue(result,clazz,key,SimpleXMLDecoder.simpleType(attributes[i].toString()));
			}
			return result;
		}
		
		private function fillValue(result:Object, clazz:Class, name:String, value:Object) : void
		{
			var type:String = null;
			var type_class:Class = null;
			var isPrimitive:Boolean = false;
			var isArray:Boolean = false;
			var isArrayCollection:Boolean = false;
			var isDate:Boolean = false;
			var existing:Object = null;
			if(clazz)
			{
				if(result.hasOwnProperty(name))
				{
					type = TypeUtility.getType(clazz,name);
					type_class = getDefinitionByName(type) as Class;
					isPrimitive = TypeUtility.isPrimitive(type);
					isArray = TypeUtility.isArray(type);
					isArrayCollection = TypeUtility.isArrayCollection(type);
					isDate = TypeUtility.isDate(type);
					if(isArray)
					{
						if(result[name] == null)
						{
							result[name] = [];
						}
						result[name].push(value);
					}
					else if(isArrayCollection)
					{
						if(result[name] == null)
						{
							result[name] = new ArrayCollection([]);
						}
						result[name].source.push(value);
					}
					else if(isDate)
					{
						result[name] = new Date(Date.parse(value));
					}
					else if(isPrimitive)
					{
						result[name] = value;
					}
					else
					{
						result[name] = value as type_class;
						if(result[name] == null && type_class != null)
						{
							result[name] = new type_class();
						}
					}
				}
			}
			else
			{
				existing = result[name];
				if(existing != null)
				{
					if(existing is Array)
					{
						existing.push(value);
					}
					else if(existing is ArrayCollection)
					{
						existing.source.push(value);
					}
					else
					{
						existing = [existing];
						existing.push(value);
						if(this.makeObjectsBindable)
						{
							existing = new ArrayCollection(existing as Array);
						}
						result[name] = existing;
					}
				}
				else
				{
					result[name] = value;
				}
			}
		}
	}
}
