package com.adobe.serializers.utils
{
   [native(instance="DictionaryObject",methods="auto",cls="DictionaryClass",gc="exact")]
   public dynamic class Dictionary
   {
      
      {
         //prototype.toJSON = function(k:String):*
         // {
         //   return "Dictionary";
         //};
         //_dontEnumPrototype(prototype);
      }
      
      public function Dictionary(weakKeys:Boolean = false)
      {
         super();
         this.init(weakKeys);
      }
      
      native private function init(param1:Boolean) : void;
   }
}
