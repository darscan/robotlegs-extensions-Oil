/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool.support
{
	public class CustomEventCommand
	{
		[Inject]
		public var event:CustomEvent;
		
		[Inject]
		public var testSuite:ICommandTest;
		
		public function execute():void
		{
			testSuite.markCommandExecuted(this);
			testSuite.deliverDataPayload(event.payload);
			
			testSuite = null;
			event = null;
		}
	
	}
}
