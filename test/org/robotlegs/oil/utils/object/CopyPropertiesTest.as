/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.utils.object
{
	import flexunit.framework.Assert;
	
	public class CopyPropertiesTest extends AbstractCopyTests
	{
		
		[Before]
		public function setUp():void
		{
			source = support_createFlatDynamicObject();
			result = copyProperties(source);
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
			copyProperties(source, result);
			testPropertiesNotNull();
			testBasicPropertiesMatch();
		}
	}
}