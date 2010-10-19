/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool
{
	
	public interface IObjectPool
	{
		function get size():uint;
		function get objectsCreated():uint;
		function get objectsRecycled():uint;
		
		function ensureSize(n:uint):void;
		
		function get():Object;
		function put(object:Object):void
	}
}