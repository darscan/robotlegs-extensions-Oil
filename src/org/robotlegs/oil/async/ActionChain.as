//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.oil.async
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	public class ActionChain
	{

		/*============================================================================*/
		/* Private Static Properties                                                  */
		/*============================================================================*/

		private static const pin:Dictionary = new Dictionary();


		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var actions:Vector.<Function>;

		private var finalCallback:Function;

		private var finished:Boolean;

		private var started:Boolean;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function ActionChain(actions:Array)
		{
			this.actions = Vector.<Function>(actions);
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function cancel(error:Object = null, data:Object = null):void
		{
			finish(error || "cancelled", data);
		}

		public function run(data:*, callback:Function):void
		{
			if (started)
				throw new IllegalOperationError("An ActionChain can only be run once");

			started = true;
			finalCallback = callback;
			pin[this] = true;
			handle(null, data);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function finish(error:Object, data:Object):void
		{
			if (finished)
				return;

			finished = true;
			actions.length = 0;
			delete pin[this];

			finalCallback(error, data);
		}

		private function handle(error:Object, data:Object):void
		{
			if (finished)
				return;

			if (error || actions.length == 0)
			{
				finish(error, data);
				return;
			}

			const action:Function = actions.shift();
			action(data, handle);
		}
	}
}
