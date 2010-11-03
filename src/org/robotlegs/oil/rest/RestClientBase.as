/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.rest
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import org.robotlegs.oil.async.Promise;
	import org.robotlegs.oil.utils.object.copyAllProperties;
	
	public class RestClientBase implements IRestClient
	{
		protected var loaders:Dictionary;
		protected var promises:Dictionary;
		protected var rootURL:String;
		protected var resultProcessors:Array;
		
		public function RestClientBase(rootURL:String = "")
		{
			this.loaders = new Dictionary();
			this.promises = new Dictionary();
			this.rootURL = rootURL;
			this.resultProcessors = [];
		}
		
		public function get(url:String, params:Object = null):Promise
		{
			if (params)
				url += createQueryString(copyAllProperties(params));
			const req:URLRequest = new URLRequest(fullUrl(url));
			return request(req);
		}
		
		protected function fullUrl(url:String):String
		{
			if (url == null || url.length == 0)
				return null;
			
			return url.indexOf("://") > -1 ? url : rootURL + url;
		}
		
		public function post(url:String, params:Object = null):Promise
		{
			const req:URLRequest = new URLRequest(fullUrl(url));
			params ||= {forcePost: true}; // Workaround: FP performs GET when no params
			req.method = URLRequestMethod.POST;
			req.data = copyAllProperties(params, new URLVariables());
			return request(req);
		}
		
		public function put(url:String, params:Object = null):Promise
		{
			params ||= {};
			params._method = 'put';
			return post(url, params);
		}
		
		public function del(url:String, params:Object = null):Promise
		{
			params ||= {};
			params._method = 'delete';
			return post(url, params);
		}
		
		public function addResultProcessor(processor:Function):IRestClient
		{
			resultProcessors.push(processor);
			return this;
		}
		
		protected function createQueryString(params:Object):String
		{
			var output:String = '';
			var entries:Array = [];
			for (var propertyName:String in params)
			{
				entries.push({
						key: propertyName,
						val: params[propertyName]
					});
			}
			if (entries.length > 0)
			{
				entries.sortOn('key');
				var parts:Array = [];
				for each (var entry:Object in entries)
					parts.push(escape(entry.key) + '=' + escape(entry.val));
				output += '?' + parts.join('&');
			}
			return output;
		}
		
		protected function request(req:URLRequest):Promise
		{
			const promise:Promise = new Promise();
			const loader:URLLoader = new URLLoader();
			promises[loader] = promise;
			loaders[promise] = loader;
			loader.addEventListener(Event.COMPLETE, handleComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleIoError);
			loader.addEventListener(ProgressEvent.PROGRESS, handleProgress);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurity);
			loader.load(req);
			return promise;
		}
		
		protected function releasePromise(promise:Promise):void
		{
			const loader:URLLoader = loaders[promise];
			delete promises[loader];
			delete loaders[promise];
		}
		
		protected function handleSecurity(event:SecurityErrorEvent):void
		{
			const promise:Promise = promises[event.target];
			releasePromise(promise);
			promise.handleError({error: "Security Error", message: event.text, event: event});
		}
		
		protected function handleProgress(event:ProgressEvent):void
		{
			const promise:Promise = promises[event.target];
			promise.handleProgress({bytesTotal: event.bytesTotal, bytesLoaded: event.bytesLoaded, event: event});
		}
		
		protected function handleIoError(event:IOErrorEvent):void
		{
			const promise:Promise = promises[event.target];
			releasePromise(promise);
			promise.handleError({error: "IO Error", message: event.text, event: event});
		}
		
		protected function handleComplete(event:Event):void
		{
			const promise:Promise = promises[event.target];
			const result:* = processResult(event.target.data);
			releasePromise(promise);
			promise.handleResult(result);
		}
		
		protected function processResult(result:*):*
		{
			const len:int = resultProcessors.length;
			for (var i:int = 0; i < len; i++)
			{
				var processor:Function = resultProcessors[i];
				result = processor(result);
			}
			return result;
		}
		
	}
}