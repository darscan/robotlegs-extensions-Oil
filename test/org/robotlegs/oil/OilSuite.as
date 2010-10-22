/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.robotlegs.oil
{
	import org.robotlegs.oil.async.AsyncTestSuite;
	import org.robotlegs.oil.utils.object.ObjectTestSuite;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class OilSuite
	{
		public var asyncTestSuite:AsyncTestSuite;
		public var objectTestSuite:ObjectTestSuite;
	}
}