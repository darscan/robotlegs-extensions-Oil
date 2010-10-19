/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool
{
	import org.robotlegs.core.IInjector;
	
	public class InjectingObjectPool extends BasicObjectPool
	{
		protected var injector:IInjector;
		
		public function InjectingObjectPool(injector:IInjector, type:Class)
		{
			super(type);
			this.injector = injector;
		}
		
		override protected function create():Object
		{
			_objectsCreated++;
			return injector.instantiate(type);
		}
	
	}
}
