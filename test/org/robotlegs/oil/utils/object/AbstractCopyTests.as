/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.utils.object
{
	import flexunit.framework.Assert;
	
	public class AbstractCopyTests
	{
		protected var source:Object;
		protected var result:Object;
		
		protected function support_checkProperty(key:String, source:Object = null, result:Object = null):void
		{
			source ||= this.source;
			result ||= this.result;
			Assert.assertEquals("Properties should match for key: " + key, source[key], result[key]);
		}
		
		protected function support_checkProperties(keys:Array, source:Object = null, result:Object = null):void
		{
			var len:int = keys.length;
			for (var i:int = 0; i < len; i++)
				support_checkProperty(keys[i], source, result);
		}
		
		public function get basicPropertyNames():Array
		{
			return ["intProperty", "numberProperty", "booleanProperty", "stringProperty"];
		}
		
		protected function support_createFlatDynamicObject():Object
		{
			return {
					intProperty: 1,
					numberProperty: 1.5,
					booleanProperty: true,
					stringProperty: "string",
					arrayProperty: [1, 1.5, true, "string"]
				};
		}
		
	}
}