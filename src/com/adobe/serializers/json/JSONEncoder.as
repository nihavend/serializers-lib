package com.adobe.serializers.json
{
   import com.adobe.serializers.utility.TypeUtility;
   import mx.collections.ArrayCollection;
   import mx.utils.DescribeTypeCache;
   
   public class JSONEncoder
   {
       
      
      private var jsonString:String;
      
      public function JSONEncoder()
      {
         super();
      }
      
      public function encode(value:*) : String
      {
         this.jsonString = this.convertToString(value);
         return this.jsonString;
      }
      
      private function convertToString(value:*) : String
      {
         if(value is String)
         {
            return this.escapeString(value as String);
         }
         if(value is Number)
         {
            return !!isFinite(value as Number)?value.toString():"null";
         }
         if(value is Boolean)
         {
            return Boolean(value)?"true":"false";
         }
         if(value is Date)
         {
            return this.dateToString(value as Date);
         }
         if(value is Array)
         {
            return this.arrayToString(value as Array);
         }
         if(value is ArrayCollection)
         {
            return this.arrayToString(ArrayCollection(value).source);
         }
         if(value is Object && value != null)
         {
            return this.objectToString(value);
         }
         return "null";
      }
      
      private function escapeString(str:String) : String
      {
         var ch:String = null;
         var hexCode:String = null;
         var zeroPad:String = null;
         var s:String = "";
         var len:Number = str.length;
         for(var i:int = 0; i < len; i++)
         {
            ch = str.charAt(i);
            switch(ch)
            {
               case "\"":
                  s = s + "\\\"";
                  break;
               case "\\":
                  s = s + "\\\\";
                  break;
               case "\b":
                  s = s + "\\b";
                  break;
               case "\f":
                  s = s + "\\f";
                  break;
               case "\n":
                  s = s + "\\n";
                  break;
               case "\r":
                  s = s + "\\r";
                  break;
               case "\t":
                  s = s + "\\t";
                  break;
               default:
                  if(ch < " ")
                  {
                     hexCode = ch.charCodeAt(0).toString(16);
                     zeroPad = hexCode.length == 2?"00":"000";
                     s = s + ("\\u" + zeroPad + hexCode);
                  }
                  else
                  {
                     s = s + ch;
                  }
            }
         }
         return "\"" + s + "\"";
      }
      
      private function arrayToString(a:Array) : String
      {
         var s:String = "";
         for(var i:int = 0; i < a.length; i++)
         {
            if(s.length > 0)
            {
               s = s + ",";
            }
            s = s + this.convertToString(a[i]);
         }
         return "[" + s + "]";
      }
      
      private function dateToString(a:Date) : String
      {
         return this.convertToString(a.toString());
      }
      
      private function objectToString(o:Object) : String
      {
         var value:Object = null;
         var key:String = null;
         var properties:Array = null;
         var i:int = 0;
         var v:XML = null;
         var s:String = "";
         var classInfo:XML = DescribeTypeCache.describeType(o).typeDescription;
         if(classInfo.@name.toString() == "Object" || classInfo.@name.toString() == "mx.utils::ObjectProxy")
         {
            for(key in o)
            {
               value = o[key];
               if(!(value is Function))
               {
                  if(s.length > 0)
                  {
                     s = s + ",";
                  }
                  s = s + (this.escapeString(key) + ":" + this.convertToString(value));
               }
            }
         }
         else
         {
            properties = TypeUtility.getProperties(o);
            if(properties != null)
            {
               for(i = 0; i < properties.length; i++)
               {
                  s = this.createString(o,s,properties[i],true);
               }
            }
            else
            {
               for each(v in classInfo..*.(name() == "variable" || name() == "accessor"))
               {
                  s = this.createString(o,s,v.@name);
               }
            }
         }
         return "{" + s + "}";
      }
      
      private function createString(obj:Object, s:String, name:String, removeUnderscore:Boolean = false) : String
      {
         if(s.length > 0)
         {
            s = s + ",";
         }
         var value:Object = obj[name];
         if(removeUnderscore)
         {
            if(name.substr(0,1) == "_")
            {
               name = name.substr(1);
            }
         }
         s = s + (this.escapeString(name) + ":" + this.convertToString(value));
         return s;
      }
   }
}
