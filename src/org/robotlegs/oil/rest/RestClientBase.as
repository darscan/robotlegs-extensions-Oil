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
		
		public function RestClientBase(rootURL:String = "")
		{
			this.loaders = new Dictionary();
			this.promises = new Dictionary();
			this.rootURL = rootURL;
		}
		
		public function get(url:String, params:Object = null):Promise
		{
			if (params)
				url += createQueryString(copyAllProperties(params));
			var req:URLRequest = new URLRequest(fullUrl(url));
			return request(req);
		}
		
		public function post(url:String, params:Object = null):Promise
		{
			var req:URLRequest = new URLRequest(fullUrl(url));
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
			var promise:Promise = new Promise();
			var loader:URLLoader = new URLLoader();
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
			var loader:URLLoader = loaders[promise];
			delete promises[loader];
			delete loaders[promise];
		}
		
		protected function handleSecurity(event:SecurityErrorEvent):void
		{
			var promise:Promise = promises[event.target];
			releasePromise(promise);
			promise.handleError({error: "Security Error", message: event.text, event: event});
		}
		
		protected function handleProgress(event:ProgressEvent):void
		{
			var promise:Promise = promises[event.target];
			promise.handleProgress({bytesTotal: event.bytesTotal, bytesLoaded: event.bytesLoaded, event: event});
		}
		
		protected function handleIoError(event:IOErrorEvent):void
		{
			var promise:Promise = promises[event.target];
			releasePromise(promise);
			promise.handleError({error: "IO Error", message: event.text, event: event});
		}
		
		protected function handleComplete(event:Event):void
		{
			var promise:Promise = promises[event.target];
			releasePromise(promise);
			// TODO: add filter
			promise.handleResult(generateObject(event.target.data));
		}
		
		protected function fullUrl(url:String):String
		{
			if (url == null || url.length == 0)
				return null;
			
			return url.indexOf("://") > -1 ? url : rootURL + url;
		}
		
		protected function generateObject(data:*):Object
		{
			return Object(data);
		}
	}
}