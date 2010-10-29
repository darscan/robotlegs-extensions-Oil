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
		function ensureSize(n:uint):void;
		function get():Object;
		function put(object:Object):void;
		
		[Bindable("sizeChange")]
		function get size():uint;
		
		[Bindable("objectsCreatedChange")]
		function get objectsCreated():uint;
		
		[Bindable("objectsRecycledChange")]
		function get objectsRecycled():uint;
	}
}