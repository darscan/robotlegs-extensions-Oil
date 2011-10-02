//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.oil.rest
{
	import org.robotlegs.oil.async.Promise;

	public interface IRestClient
	{
		function addParamsTransform(transform:Function):IRestClient;
		function addResultProcessor(processor:Function):IRestClient;
		function del(url:String, params:Object = null):Promise;
		function get(url:String, params:Object = null):Promise;
		function post(url:String, params:Object = null):Promise;
		function put(url:String, params:Object = null):Promise;
	}
}
