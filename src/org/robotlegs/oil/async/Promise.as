//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.oil.async
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name="errorChange", type="flash.events.Event")]
	[Event(name="progressChange", type="flash.events.Event")]
	[Event(name="resultChange", type="flash.events.Event")]
	[Event(name="statusChange", type="flash.events.Event")]
	public class Promise extends EventDispatcher
	{

		/*============================================================================*/
		/* Public Static Properties                                                   */
		/*============================================================================*/

		public static const CANCELLED:String = "cancelled"; // NO PMD

		public static const COMPLETE:String = "complete"; // NO PMD

		public static const FAILED:String = "failed"; // NO PMD

		public static const PENDING:String = "pending"; // NO PMD


		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		protected var _error:*;

		[Bindable("errorChange")]
		public function get error():*
		{
			return _error;
		}

		protected var _progress:*;

		[Bindable("progressChange")]
		public function get progress():*
		{
			return _progress;
		}

		protected var _result:*;

		[Bindable("resultChange")]
		public function get result():*
		{
			return _result;
		}

		protected var _status:String = PENDING;

		[Bindable("statusChange")]
		public function get status():String
		{
			return _status;
		}

		/*============================================================================*/
		/* Protected Properties                                                       */
		/*============================================================================*/

		protected var errorHandlers:Array = [];

		protected var progressHandlers:Array = [];

		protected var resultHandlers:Array = [];

		protected var resultProcessors:Array = [];


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function addErrorHandler(handler:Function):Promise
		{
			if (status == FAILED)
				handler(this);
			else if (status == PENDING)
				errorHandlers.push(handler);
			return this;
		}

		public function addProgressHandler(handler:Function):Promise
		{
			if (status == FAILED || status == COMPLETE || status == CANCELLED)
				handler(this);
			else if (status == PENDING)
				progressHandlers.push(handler);
			return this;
		}

		public function addResultHandler(handler:Function):Promise
		{
			if (status == COMPLETE)
				handler(this);
			else if (status == PENDING)
				resultHandlers.push(handler);
			return this;
		}

		public function addResultProcessor(processor:Function):Promise
		{
			if (status == PENDING)
				resultProcessors.push(processor);
			return this;
		}

		public function cancel():Promise
		{
			setStatus(CANCELLED);
			resetHandlers();
			return this;
		}

		public function handleError(value:*):Promise // NO PMD
		{
			setError(value);
			setStatus(FAILED);
			handle(errorHandlers);
			resetHandlers();
			return this;
		}

		public function handleProgress(value:*):Promise // NO PMD
		{
			setProgress(value);
			handle(progressHandlers);
			return this;
		}

		public function handleResult(value:*):Promise // NO PMD
		{
			new ActionChain(resultProcessors)
				.run(value, function(err:Object, data:Object = null):void
				{
					if (err)
					{
						handleError(err);
						return;
					}
					setResult(data);
					setStatus(COMPLETE);
					handle(resultHandlers);
					resetHandlers();
				});
			return this;
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

		// Helpers

		protected function handle(handlers:Array):void
		{
			const len:int = handlers.length;
			for (var i:int = 0; i < len; i++)
			{
				var handler:Function = handlers[i];
				handler(this);
			}
		}

		protected function resetHandlers():void
		{
			resultHandlers = [];
			resultProcessors = [];
			errorHandlers = [];
			progressHandlers = [];
		}

		protected function setError(value:*):void
		{
			if (_error != value)
			{
				_error = value;
				dispatchEvent(new Event("errorChange"));
			}
		}

		protected function setProgress(value:*):void
		{
			if (_progress != value)
			{
				_progress = value;
				dispatchEvent(new Event("progressChange"));
			}
		}

		protected function setResult(value:*):void
		{
			if (_result != value)
			{
				_result = value;
				dispatchEvent(new Event("resultChange"));
			}
		}

		protected function setStatus(value:String):void
		{
			if (_status != value)
			{
				_status = value;
				dispatchEvent(new Event("statusChange"));
			}
		}
	}
}
