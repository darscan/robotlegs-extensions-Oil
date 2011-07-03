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

		private var hasRun:Boolean;

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

		public function run(data:*, callback:Function):void
		{
			if (hasRun)
				throw new IllegalOperationError("An ActionChain can only be run once");

			hasRun = true;

			finalCallback = callback;

			pin[this] = true;

			actionCallback(null, data);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function actionCallback(err:Object, data:Object = null):void
		{
			if (err || actions.length == 0)
			{
				finish(err, data);
				return;
			}

			const action:Function = actions.shift();
			action(data, actionCallback);
		}

		private function finish(err:Object, data:Object):void
		{
			finalCallback(err, data);
			actions.length = 0;
			delete pin[this];
		}
	}
}
