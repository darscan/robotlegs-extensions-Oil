//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

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
	import org.robotlegs.oil.async.Promise;
	import org.robotlegs.oil.utils.object.copyAllProperties;

	public class RestClientBase implements IRestClient
	{

		/*============================================================================*/
		/* Protected Properties                                                       */
		/*============================================================================*/

		protected var loaders:Dictionary = new Dictionary();

		protected var paramTransforms:Array = [];

		protected var promises:Dictionary = new Dictionary();

		protected var resultProcessors:Array = [];

		protected var rootURL:String;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function RestClientBase(rootURL:String = "")
		{
			this.rootURL = rootURL;
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function addParamsTransform(transform:Function):IRestClient
		{
			paramTransforms.push(transform);
			return this;
		}

		public function addResultProcessor(processor:Function):IRestClient
		{
			resultProcessors.push(processor);
			return this;
		}

		public function del(url:String, params:Object = null):Promise
		{
			// note: do not transform params as this will be done in post
			params ||= {};
			// method override, see: Rack::MethodOverride
			params._method = 'delete';
			return post(url, params);
		}

		public function get(url:String, params:Object = null):Promise
		{
			params = transform(params, paramTransforms);
			if (params)
				url += createQueryString(copyAllProperties(params));
			const req:URLRequest = new URLRequest(fullUrl(url));
			return request(req);
		}

		public function post(url:String, params:Object = null):Promise
		{
			const req:URLRequest = new URLRequest(fullUrl(url));
			req.method = URLRequestMethod.POST;
			params = transform(params, paramTransforms);
			// params ||= { forcePost: true }; // Workaround: FP performs GET when no params
			// FlashBuilder 4.5 has a problem with the mushroom operator, hence:
			if (!params)
				params = {forcePost: true};
			req.data = copyAllProperties(params, new URLVariables());
			return request(req);
		}

		public function put(url:String, params:Object = null):Promise
		{
			// note: do not transform params as this will be done in post
			params ||= {};
			// method override, see: Rack::MethodOverride
			params._method = 'put';
			return post(url, params);
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

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

		protected function fullUrl(url:String):String
		{
			if (url == null || url.length == 0)
				return null;

			return url.indexOf("://") > -1 ? url : rootURL + url;
		}

		protected function handleComplete(event:Event):void
		{
			const promise:Promise = promises[event.target];
			const result:* = event.target.data;
			promise.handleResult(result);
			releasePromise(promise);
		}

		protected function handleIoError(event:IOErrorEvent):void
		{
			const promise:Promise = promises[event.target];
			releasePromise(promise);
			promise.handleError({error: "IO Error", message: event.text, event: event});
		}

		protected function handleProgress(event:ProgressEvent):void
		{
			const promise:Promise = promises[event.target];
			promise.handleProgress({bytesTotal: event.bytesTotal, bytesLoaded: event.bytesLoaded, event: event});
		}

		protected function handleSecurity(event:SecurityErrorEvent):void
		{
			const promise:Promise = promises[event.target];
			releasePromise(promise);
			promise.handleError({error: "Security Error", message: event.text, event: event});
		}

		protected function releasePromise(promise:Promise):void
		{
			const loader:URLLoader = loaders[promise];
			delete promises[loader];
			delete loaders[promise];
		}

		protected function request(req:URLRequest):Promise
		{
			const promise:Promise = new Promise();
			resultProcessors.forEach(function(processor:Function, ... rest):void
			{
				promise.addResultProcessor(processor);
			});
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

		protected function transform(value:*, transforms:Array):*
		{
			const len:int = transforms.length;
			for (var i:int = 0; i < len; i++)
			{
				var processor:Function = transforms[i];
				value = processor(value);
			}
			return value;
		}
	}
}
