//------------------------------------------------------------------------------
//  Copyright (c) 2010 the original author or authors 
//  All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.oil.async
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class ThrottledCallback
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var delegate:Function;

		private var timer:Timer;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function ThrottledCallback(delay:Number = 250)
		{
			timer = new Timer(delay, 1);
			timer.addEventListener(TimerEvent.TIMER, onTick);
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function callLater(method:Function, ... args):void
		{
			timer.reset();
			delegate = function():void
			{
				method.apply(null, args);
			};
			timer.start();
		}

		public function cancel():void
		{
			timer.reset();
			delegate = null;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function onTick(event:TimerEvent):void
		{
			delegate && delegate();
			delegate = null;
		}
	}
}