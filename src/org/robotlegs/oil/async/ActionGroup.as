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

	public class ActionGroup
	{

		/*============================================================================*/
		/* Private Static Properties                                                  */
		/*============================================================================*/

		private static const pin:Dictionary = new Dictionary();


		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var actions:Vector.<Function>;

		private var errors:Array;

		private var finalCallback:Function;

		private var hasFinished:Boolean;

		private var hasRun:Boolean;

		private var results:Array = [];

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function ActionGroup(actions:Array)
		{
			this.actions = Vector.<Function>(actions);
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function run(data:*, callback:Function):void
		{
			if (hasRun)
				throw new IllegalOperationError("An ActionGroup can only be run once");

			hasRun = true;
			hasFinished = false;
			finalCallback = callback;
			pin[this] = true;
			actions.forEach(function(action:Function, ... rest):void
			{
				action(data, handleAction);
			});
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function finish():void
		{
			if (hasFinished)
				return;

			hasFinished = true;
			actions.length = 0;
			delete pin[this];

			finalCallback(errors, results);
		}

		private function handleAction(err:Object, data:Object = null):void
		{
			results.push(data);

			if (err)
			{
				errors ||= [];
				errors.push(err);
				finish();
			}

			if (results.length == actions.length)
			{
				finish();
			}
		}
	}
}
