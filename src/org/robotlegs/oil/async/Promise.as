/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.async
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Promise extends EventDispatcher
	{
		public static const PENDING:String = "pending"; // NO PMD
		public static const COMPLETE:String = "complete"; // NO PMD
		public static const FAILED:String = "failed"; // NO PMD
		public static const CANCELLED:String = "cancelled"; // NO PMD
		
		public function Promise()
		{
			resetHandlers();
		}
		
		protected function resetHandlers():void
		{
			resultHandlers = [];
			resultProcessors = [];
			errorHandlers = [];
			progressHandlers = [];
		}
		
		// Add Handlers
		
		protected var resultHandlers:Array;
		
		public function addResultHandler(handler:Function):Promise
		{
			if (status == COMPLETE)
				handler(this);
			else if (status == PENDING)
				addNewHandler(resultHandlers, handler);
			return this;
		}
		
		protected var resultProcessors:Array;
		
		public function addResultProcessor(processor:Function):Promise
		{
			if (status == PENDING)
				addNewHandler(resultProcessors, processor);
			return this;
		}
		
		protected var errorHandlers:Array;
		
		public function addErrorHandler(handler:Function):Promise
		{
			if (status == FAILED)
				handler(this);
			else if (status == PENDING)
				addNewHandler(errorHandlers, handler);
			return this;
		}
		
		protected var progressHandlers:Array;
		
		public function addProgressHandler(handler:Function):Promise
		{
			if (status == FAILED || status == COMPLETE || status == CANCELLED)
				handler(this);
			else if (status == PENDING)
				addNewHandler(progressHandlers, handler);
			return this;
		}
		
		// Handle
		
		public function handleResult(value:*):void // NO PMD
		{
			value = processResult(value);
			setResult(value);
			setStatus(COMPLETE);
			handle(resultHandlers);
			resetHandlers();
		}
		
		public function handleError(value:*):void // NO PMD
		{
			setError(value);
			setStatus(FAILED);
			handle(errorHandlers);
			resetHandlers();
		}
		
		public function handleProgress(value:*):void // NO PMD
		{
			setProgress(value);
			handle(progressHandlers);
		}
		
		public function cancel():void
		{
			setStatus(CANCELLED);
			resetHandlers();
		}
		
		// Bindables
		
		protected var _status:String = PENDING;
		
		[Bindable("statusChange")]
		public function get status():String
		{
			return _status;
		}
		
		protected function setStatus(value:String):void
		{
			if (_status != value)
			{
				_status = value;
				dispatchEvent(new Event("statusChange"));
			}
		}
		
		protected var _result:*;
		
		[Bindable("resultChange")]
		public function get result():*
		{
			return _result;
		}
		
		protected function setResult(value:*):void
		{
			if (_result != value)
			{
				_result = value;
				dispatchEvent(new Event("resultChange"));
			}
		}
		
		protected var _error:*;
		
		[Bindable("errorChange")]
		public function get error():*
		{
			return _error;
		}
		
		protected function setError(value:*):void
		{
			if (_error != value)
			{
				_error = value;
				dispatchEvent(new Event("errorChange"));
			}
		}
		
		protected var _progress:*;
		
		[Bindable("progressChange")]
		public function get progress():*
		{
			return _progress;
		}
		
		protected function setProgress(value:*):void
		{
			if (_progress != value)
			{
				_progress = value;
				dispatchEvent(new Event("progressChange"));
			}
		}
		
		// Helpers
		
		protected function addNewHandler(handlers:Array, handler:Function):void
		{
			if (handlers.indexOf(handler) == -1)
				handlers.push(handler);
		}
		
		protected function handle(handlers:Array):void
		{
			const len:int = handlers.length;
			for (var i:int = 0; i < len; i++)
			{
				var handler:Function = handlers[i];
				handler(this);
			}
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