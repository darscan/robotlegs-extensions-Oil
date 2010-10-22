/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.utils.object
{
	import flexunit.framework.Assert;
	
	import org.robotlegs.oil.utils.object.support.FlatSealedObject;
	import org.robotlegs.oil.utils.object.support.NestedSealedObject;
	
	public class CopyAllPropertiesTest extends AbstractCopyTests
	{
		
		[Before]
		public function setUp():void
		{
			source = support_createFlatDynamicObject();
			result = copyAllProperties(source);
		}
		
		[After]
		public function tearDown():void
		{
			source = null;
			result = null;
		}
		
		[Test]
		public function testPropertiesNotNull():void
		{
			Assert.assertNotNull("Result should not be null", result);
		}
		
		[Test]
		public function testBasicPropertiesMatch():void
		{
			support_checkProperties(basicPropertyNames);
		}
		
		[Test]
		public function testCopiesInto():void
		{
			result = {};
			copyAllProperties(source, result);
			testPropertiesNotNull();
			testBasicPropertiesMatch();
		}
		
		[Test]
		public function testNestedPropertiesMatch():void
		{
			source = support_createNestedDynamicObject();
			result = copyAllProperties(source);
			support_checkProperties(basicPropertyNames, source.nestedObject, result.nestedObject);
		}
		
		protected function support_createNestedDynamicObject():Object
		{
			var value:Object = support_createFlatDynamicObject();
			value.nestedObject = support_createFlatDynamicObject();
			return value;
		}
		
		[Test]
		public function testNestedCopiesInto():void
		{
			result = {};
			source = support_createNestedDynamicObject();
			copyAllProperties(source, result);
			support_checkProperties(basicPropertyNames, source.nestedObject, result.nestedObject);
		}
		
		[Test]
		public function testArrayOfDynamicObjects():void
		{
			source = [support_createFlatDynamicObject(), support_createNestedDynamicObject()];
			result = copyAllProperties(source);
			support_checkProperties(basicPropertyNames, source[0], result[0]);
			support_checkProperties(basicPropertyNames, source[1].nestedObject, result[1].nestedObject);
		}
		
		[Test]
		public function testBasicPropertiesMatchForFlatSealedObject():void
		{
			source = new FlatSealedObject();
			result = copyAllProperties(source);
			support_checkProperties(basicPropertyNames);
		}
		
		[Test]
		public function testBasicPropertiesMatchForNestedSealedObject():void
		{
			source = new NestedSealedObject();
			result = copyAllProperties(source);
			support_checkProperties(basicPropertyNames, source.nestedObject, result.nestedObject);
		}
		
		[Test]
		public function testArrayOfSealedObjects():void
		{
			source = [new FlatSealedObject(), new NestedSealedObject()];
			result = copyAllProperties(source);
			support_checkProperties(basicPropertyNames, source[0], result[0]);
			support_checkProperties(basicPropertyNames, source[1].nestedObject, result[1].nestedObject);
		}
	}
}