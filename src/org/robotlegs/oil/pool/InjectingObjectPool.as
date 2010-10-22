/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool
{
	import org.robotlegs.core.IInjector;
	import org.robotlegs.oil.utils.object.copyProperties;
	
	public class InjectingObjectPool extends BasicObjectPool
	{
		protected var injector:IInjector;
		
		public function InjectingObjectPool(injector:IInjector, type:Class, properties:Object = null)
		{
			super(type, properties);
			this.injector = injector;
		}
		
		override protected function create():Object
		{
			_objectsCreated++;
			var instance:Object = injector.instantiate(type);
			copyProperties(properties, instance);
			return instance;
		}
	
	}
}
