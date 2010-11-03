/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.rest
{
	import org.robotlegs.oil.async.Promise;
	
	public interface IRestClient
	{
		function get(url:String, params:Object = null):Promise;
		function post(url:String, params:Object = null):Promise;
		function put(url:String, params:Object = null):Promise;
		function del(url:String, params:Object = null):Promise;
		function addResultProcessor(processor:Function):IRestClient;
	}
}